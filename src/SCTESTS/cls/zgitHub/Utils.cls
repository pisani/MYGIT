/// Updated at 03/21/2021 05:23:42
Class zgitHub.Utils Extends %RegisteredObject
{

/// This utility is used to create, populate and link a remote GitHub repository to an IRIS namespace(s)
/// 
/// Creates a Git local repository, add code from Instance, and create GitHub repository pushing all
/// code from created local repository to GitHub remote.
ClassMethod CreateMyGit(SSLConfig, gUsername, gAccessToken, gRepo, gComment, gMask, lFolder)
{

	
	
	Write !,"Specify Namespace(s) with source for of your application: "
	Write !,"Use <ns>:<qualify>.<type>, where ns = namespace, qualify=name of Code, type=cls/rtn/inc/etc."
	write !!
	write !,"For example: USER:*.cls,%SYS:Z*.mac for all classes in USER namespace, and Z* routines in IRISSYS"
	Read !,"Enter selection: ",gMask
	set:gMask="" gMask="USER:*,%SYS:Z*.mac,%SYS:z*.mac,USER:*.csp"
	
	Read !,"SSL Confuration to use",SSLConfig
	set SSLConfig="GMail SSL"
	
	Read !,"Enter GitHub username: ",gUsername
	set gUsername="pisani"
	
	USE 0:/ECHO=0 Read !,"Enter GitHub Access Token ",gAccessToken USE 0:/echo=1
	set gAccessToken="ecb349281c01ffab1209de7a7909001e572a709e"
	
	Read !,"Enter the GitHub repository name you want to create: ",gRepo
	set:gRepo="" gRepo="MYGIT"
		
	Read !,"Enter the Comment for initial commit: ",gComment
	set gComment="Initial Commit via "_..%ClassName(1)
	
	Read !,"Enter empty local folder to hold exported Classes, etc: ",lFolder
	set:lFolder="" lFolder="c:\temp\mygit"


	
	set gURL="https://github.com/"_gUsername_"/"_gRepo_".git"
	write !,"Creating remote GitHub repository: ",gURL
	write !,"Exporting routines and classes from these namespace(s): ",gMask
	write !,"Using temporary local folder: ",lFolder
	kill path
	for i=1:1:$l(gMask,",") {
		set selection=$p(gMask,",",i)
		set:$p(selection,":")="" selection=$namespace_selection
		set:$p(selection,":",2)="" selection=selection_"*"
		
		set ns=$p(selection,":") set:ns="" ns=$zu(5)
		set mask=$p(selection,":",2)
		if mask="*"!(mask="") {
			for mask="*.cls","*.mac","*.inc","*.dfi","*.csp" { set path(ns,mask)="\"_ns_"\"_$p(mask,".",2)_"\" }
		} else {
			set path(ns,mask)="\"_ns_"\"_$p(mask,".",2)_"\"  
		}
	}
	zw path
	
	#; Export components to folders 
	set ns=""
	set oNS=$namespace
	for  {
		set ns=$order(path(ns)) quit:ns=""
		zn ns
		set mask=""
		for  {
			set mask=$order(path(ns,mask)) quit:mask=""
			do ..workdir(lFolder_"/src/"_ns)
			do ..export(mask)
		}
	}
	zn oNS
	
	#; Create git repository
	set http=##class(%Net.HttpRequest).%New()
	
	do http.SetHeader("Authorization","token "_gAccessToken)
	set http.SSLConfiguration=SSLConfig
	set body={}
	set body.name=gRepo
	do http.EntityBody.Write(body.%ToJSON())
	do http.Post("https://api.github.com/user/repos")
	 
	#; Create local folder
	set tSC=##class(%File).CreateDirectory(lFolder)
	
	
	#; Initialise local folder
	set cmd="cd """_lFolder_""" && git init "_lFolder
	write !,cmd
	set osStatus=$zf(-1,cmd) WRITE " -> ",osStatus
	
	#; point origin to Master
	set cmd="cd """_lFolder_""" && git remote add origin "_gURL
	write !,cmd
	set osStatus=$zf(-1,cmd) WRITE " -> ",osStatus
	
	
	#; Stage all 
	set cmd="cd """_lFolder_""" && git add ."
	write !,cmd
	set osStatus=$zf(-1,cmd) WRITE " -> ",osStatus
	
	#; Commit all 
	set cmd="cd """_lFolder_""" && git commit -m """_gComment_""""
	write !,cmd
	set osStatus=$zf(-1,cmd) WRITE " -> ",osStatus
	
	#; git push to master
	set cmd="cd """_lFolder_""" && git push -u origin master"
	write !,cmd
	set osStatus=$zf(-1,cmd) WRITE " -> ",osStatus
	
	#; clean out local folder.
}

/// export all available code
ClassMethod export(mask = "", generated = 0, system = 0, percent = 0, mapped = 0, dfi = 0)
{
	#define export(%code, %file) 	set sc = $system.OBJ.ExportUDL(%code, %file,"/diffexport") ##continue
								 	do:'sc $system.OBJ.DisplayError(sc)

	#define isGenerated(%code) 		##class(%RoutineMgr).IsGenerated( %code )
	#define isPercented(%code) 		("%" = $e(%code))
	#define isMapped(%code) 		##class(%RoutineMgr).IsMapped( %code )
	#define log 					write !, code, " -> ", $piece(filename,..workdir(),2), " "
						
	write "#; Exporting "_mask_" to ", ..workdir() 
	#; classes
	if $p(mask,".",$l(mask,"."))="cls" { 
		set rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:Summary")
		
		if rs.Execute() 
		{
			while rs.%Next()
			{ 
				set code = rs.Name _ ".cls", isSystem = rs.System
				if ( 'system && isSystem ) continue
				if ( 'generated && $$$isGenerated( code ) ) continue
				if ( 'percent && $$$isPercented( code ) ) continue
				if ( 'mapped && $$$isMapped( code ) ) continue
				if ( '..checkMasks( code, mask ) ) continue
				
				set filename = ..filename( code )
				do ..mkdir( filename )
				//$$$log
				$$$export( code, filename )
			} 
			set rs=""
		}
	}
	
	#; routines
	if $p(mask,".",$l(mask,"."))="mac" { 
		set rs = ##class(%ResultSet).%New("%Routine:RoutineList")
		if rs.Execute() 
		{
			while rs.%Next() 
			{
		 		set code = rs.Name
		 		//write code,!
		 		if ( 'generated && $$$isGenerated( code ) ) continue
		 		if ( 'percent && $$$isPercented( code ) ) continue
				if ( 'mapped && $$$isMapped( code ) ) continue
				if ( '..checkMasks( code, mask ) ) continue
				
				set filename = ..filename( code )
				do ..mkdir( filename )
				$$$log
				$$$export( code, filename )

			} 
			set rs=""
		}
	}

	#; Includes
	if $p(mask,".",$l(mask,"."))="inc" { 
		set rs = ##class(%ResultSet).%New("%Routine:RoutineList")
		if rs.Execute() 
		{
			while rs.%Next() 
			{
		 		set code = rs.Name
		 		//write code,!
		 		if ( 'generated && $$$isGenerated( code ) ) continue
		 		if ( 'percent && $$$isPercented( code ) ) continue
				if ( 'mapped && $$$isMapped( code ) ) continue
				if ( '..checkMasks( code, mask ) ) continue
				
				set filename = ..filename( code )
				do ..mkdir( filename )
				$$$log
				$$$export( code, filename )

			} 
			set rs=""
		}
	}
	
	#; csp files
	; # TODO #   Not yet supported
	if $p(mask,".",$l(mask,"."))="csp" { 
	
		while 0 {
		do ..GetCSPAppsForNamespace(.cspApps,$NAMESPACE)
		set app=""
		
		for  {
			set app=$Order(cspApps(app)) quit:app=""
			//if $e(iSel,"*")="*" continue:$extract(app,1,$l(app))'=$e(iSel,1,$l(iSel)-1)
			//if $e(iSel,"*")'="*" continue:app'=iSel
			
			set mapToPath=..filename(app_".CSP")
		 
			Set srcPath = cspApps(app) 
			Set dstPath = ..workdir()_mapToPath 

			Set sc = ##class(%File).CopyDir(srcPath, dstPath, 1)
	 	
		}
		}
	}
	
	#; dfi
	if $p(mask,".",$l(mask,"."))="dfi" { 
	
		do ..fixDashIntoName()
		#define export(%code,%file) set sc = ##class(%DeepSee.UserLibrary.Utils).%Export( %code, %file, 0 ) 
		
		set sql = "Select id, fullName as Name, documentName From %DeepSee_UserLibrary.FolderItem"
	    set rs = ##class(%SQL.Statement).%ExecDirect( .stm, sql )
		while rs.%Next() 
		{
			set code = rs.Name
			set filename = ..filename( code_".dfi" )
			set documentName = rs.documentName
			
			if ($L(code,"$TRASH")>1) continue
			
			if ( 'generated && $$$isGenerated( code ) ) continue
		 	if ( 'percent && $$$isPercented( code ) ) continue
			if ( 'mapped && $$$isMapped( code ) ) continue
			if ( '..checkMasks(documentName, mask) ) continue
			
			do ..mkdir( filename )
			
			if dfi
			{
				$$$log
				$$$export( code, filename)
			}
			elseif ('dfi)
			{
				set documentName = $replace(documentName,"/","-")
				set filename = $extract(filename,1,*-4)
				do ..fixXMLLine(documentName,filename_".xml")
			}

		} 
		set rs=""
	}
		
	#;DeepSee artefacts
	// exports all DeepSee Artifaccts. Need to enhance this to allow for a mask
	do ..exportDeepSeeArtefacts()
	
	write !, "#; Done",!!
	return $$$OK
}

/// get or set working directory for export/import source
ClassMethod workdir(workdir)
{
	set:$d(workdir) workdir = ##class(%File).NormalizeDirectory(workdir)
	set gln = ..gln() 
	set:$d(workdir) @gln = workdir
	
	///zu(12) namespace directory by default
	#define nsdir $zu(12,"")
	return $g(@gln, $$$nsdir)
}

ClassMethod checkMasks(name As %String, masks As %String) As %Boolean
{
	return:masks="" 1
	return:name="" 0
	
	set name = $zcvt(name,"l")
	set masks =  $zcvt(masks,"l")
	
	for i=1:1:$l(masks,",")
	{
		set pattern = "^"
		set mask = $p(masks, ",", i)
		
		for index=1:1:$l(mask)
		{
			set char = $e(mask, index)
    		set pattern = pattern _ $case(char,
    									  ".":"\.",
    									  "?":".",
    									  "*":".*",
    									     :char
    									  )	
		}
		set pattern = pattern _ "$|"
	}
	set pattern = $e(pattern,1,*-1)
	set matcher=##class(%Regex.Matcher).%New(pattern, name)
	do matcher.Locate() 
	return $select(matcher.Group="":0, 1:1)
}

/// test.dfi -> /dfi/test.dfi
/// test.cls -> /cls/test.cls
/// testpkg.test.cls -> /cls/testpkg/test.cls
/// etc
ClassMethod filename(code)
{
	#define log(%dir,%sc) w !, "mkdir ", %dir, " ", sc

	set wd = ..workdir()

	if '##class(%File).DirectoryExists( wd ) {
		set sc = ##class(%File).CreateDirectoryChain( wd )
		$$$log(wd,sc)
	}

	set ext = $p( code, ".", * ), ext = $zcvt( ext, "l" )
	#; for each type - different directory

	set:ext'="" wd = ##class(%File).NormalizeDirectory( ext, wd )

	#; directory must exist before any call (%File).NormalizeFilename( , wd)
	if '##class(%File).DirectoryExists( wd ) 
	{
		set sc = ##class(%File).CreateDirectoryChain( wd )
		$$$log(wd,sc)
	}

	set filename = ##class(%File).NormalizeFilename( code, wd )
	#; lowercase file extension
	set $p(filename,".",*)=ext
	//B:code="DPRep.Rest.JSON.cls" "L"
	
	#; for *.cls Package.Subpackage.ClassName.cls -> Folder/Subfolder/ClassName.cls
	if (ext="cls") || (ext="gbl") 
	{
		set dirs = $piece( code, ".",1, *-2 ), dirs = $translate( dirs, ".", "/" )
		set relpath = dirs _ "/" _ $piece( code, ".", *-1, * ) ;
		set filename = ##class(%File).NormalizeFilename( relpath, wd )
	}

	return filename
}

ClassMethod mkdir(filename As %String) As %Status
{
	set sc = $$$OK
	set path = ##class(%File).GetDirectory(filename) 
	if '##class(%File).DirectoryExists(path) 
	{
		set sc = ##class(%File).CreateDirectoryChain(path) 
	}
	return sc
}

ClassMethod fixDashIntoName()
{
	set sql = "Select id, fullName as Name, documentName From %DeepSee_UserLibrary.FolderItem"
    set rs = ##class(%SQL.Statement).%ExecDirect( .stm, sql )
    while rs.%Next() {
		if $find(rs.Name, "-"){
			//write rs.Name," -> "
			set item = ##class(%DeepSee.UserLibrary.FolderItem).%OpenId(rs.id)
			set item.name = $replace(item.name,"-"," ")
			//write item.name,!
			do item.%Save()
		}
    }
    kill rs
}

ClassMethod fixXMLLine(documentName, filename) As %Status
{
	set stream = ##class(%Stream.FileBinary).%New()
	do stream.LinkToFile(filename)
	do $system.OBJ.ExportToStream(documentName, .stream)

	set matcher=##class(%Regex.Matcher).%New("<Export generator=.+>")
	set matcher.Text = stream.Read(stream.Size)
	set data = matcher.ReplaceFirst("<Export generator=""Cache"">")
	
	do stream.Clear()
	do stream.Write(data)
	return stream.%Save()
}

ClassMethod exportDeepSeeArtefacts() As %Status
{
	set sc = $$$OK
	set artefacts = $listbuild("DeepSee.Variables","DeepSee.TermList","DeepSee.CalcMbrs")
	
	for i=1:1:$listlength(artefacts)
	{
		set artefact = $list(artefacts,i)
		continue:$data(@("^"_artefact))=0
		
		set artefact = artefact_".GBL"
		set filename = ..filename(artefact)
		do ..mkdir(filename)

		set sc = ..fixXMLLine(artefact, filename_".xml")
	}

	return sc
}

/// gl[obal] n[ame] - storage for settings
ClassMethod gln() [ CodeMode = expression, Private ]
{
"^"_$classname()
}

/// Return array of CSP Apps and Physical Paths for CSP (non-REST) applicationsn defined out of this Namespace
ClassMethod GetCSPAppsForNamespace(ByRef cspAppArray, namespace)
{
	; find the Web Applications used by this namespace.
	set ns=$NAMESPACE
	zn "%SYS"

	kill cspAppArray
	set tResult = ##class(%SQL.Statement).%ExecDirect(.tStatement,"CALL Security.Applications_Detail('*',2)")
	while tResult.%Next() {
		// only for this namespace, where CSP web app does not represent a REST service..
		if tResult.%Get("NameSpace")=namespace,(tResult.%Get("DispatchClass")="") {
			set cspAppArray(tResult.%Get("Name"))=$system.CSP.GetFileName(tResult.%Get("Name")_"/")
		}
	}
	kill tResult
	zn ns
}

}

