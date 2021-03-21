Include Studio.SourceControl

/// Updated at 03/15/2021 13:08:54
Class Studio.SourceControl.v2.SourceControl Extends %Studio.SourceControl.Base
{

/// This aids in identifying the SC hook output amongst other console output
Parameter PREFIX = {"** "_..%ClassName(1)_": "};

/// First menu item that appears
Parameter FIRSTMENUITEM = "Add";

/// Not supported item types (or that you don't want to be exported/imported to/from git)
Parameter NOTSUPPORTEDTYPES = "PRJ,PKG";

/// Extensions that can not be exported as UDL. XML will always be used.
Parameter NOTUDLEXTENSIONS = {$lb("hl7","dfi","lut")};

/// Source Control interface class
Property Commands As %RegisteredObject [ Private ];

/// Logger instance to handle output of information, eror and debug messages
Property LogUtils As %RegisteredObject [ Private ];

Property IsControlled As %Boolean [ Private ];

Property IsCheckedOut As %Boolean [ Private ];

Property IsEditable As %Boolean [ Private ];

Property IsAdded As %Boolean [ Private ];

Property IsGitInitialised As %Boolean [ Private ];

Property OnReloadFiles As %List [ Private ];

Property OnWorkDirLoad As %List [ Private ];

Property OnPull As %List [ Private ];

/// Export files in UDL format
Property UseUDL As %Boolean [ InitialExpression = 1, Private ];

/// Use always XML as filename extension 
Property UseXMLExtension As %Boolean [ InitialExpression = 0, Private ];

/// This is the configuration settings ID. By default, this is currently hardcoded to '0', meaning all users
/// connecting to this namespace will utilise one common configuration for integrating with git.
/// Concievable, however, this can be extended so that different users could define their own configuration, however, this has not 
/// been implemented.
Property ConfigID As %String [ InitialExpression = "0" ];

XData Menu
{
<MenuBase>
<Menu Name="%SourceMenu" Type="0">
<MenuItem Name="Add" Save="100"/>
<MenuItem Name="Unstage"/>
<MenuItem Name="Revert changes" Save="100"/>
<MenuItem Name="Log"/>
<MenuItem Name="Diff"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="Status"/>
<MenuItem Name="Add All Changes"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="Commit..."/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="*Switch to Branch..."/>
<MenuItem Name="*Create and Switch to Branch..."/>
<MenuItem Name="*Diff with Branch..."/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="*Merge with..."/>
<MenuItem Name="*Abort merge"/>
<MenuItem Name="*Load status changes"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="*Diff with origin"/>
<MenuItem Name="Pull origin->local"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="Push local->origin"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="*Workdir - Load files"/>
</Menu> 
<Menu Name="%SourceContext" Type="1">
<MenuItem Name="Add" Save="100"/>
<MenuItem Name="Unstage"/>
<MenuItem Name="Revert changes" Save="100"/>
<MenuItem Name="Log"/>
<MenuItem Name="Diff"/>
</Menu>
<Menu Name="OtherContextCommands" Type="1">
<MenuItem Name="OtherContextMenu-A" Save="100"/>
<MenuItem Name="OtherContextMenu-B"/>
</Menu>  
</MenuBase>
}

/// Studio base class calls this method upon login.
/// Initialise and load configuration settings and show status of work dir.
/// 
Method Login(Name As %String, Password As %String) As %Status
{
			
	set tSC=$$$OK
	set ..IsGitInitialised=0 
	
	try {
		set logUtilitiesClass	=$$$GetConfig("LogUtils", "Studio.SourceControl.v2.Utils")
		set commandsClass		=$$$GetConfig("Commands", "Studio.SourceControl.v2.GITClient")
		
		set ..LogUtils=$classmethod(logUtilitiesClass,"%New",$$$GetConfig("logLevel", "2"))
		do ..LogUtils.Info("=========================================================")
    	do ..LogUtils.Info("Source Control initialising:")
    	
    	set gitpath 			= $$$GetConfig("gitpath", "")
		set workdir 			= $$$GetConfig("workdir","")
		set homedir 			= $$$GetConfig("homedir","")
		set output 				= $$$GetConfig("output","")
		set error 				= $$$GetConfig("error","")
		set authorname 			= $$$GetConfig("authorname","")
		set authoremail 		= $$$GetConfig("authoremail","")
		
    	set ..Commands=$classmethod(commandsClass,"%New",gitpath, workdir, homedir,authorname, authoremail, output, error)
    	set ..Commands.LogUtils =..LogUtils
    	
		set ..OnWorkDirLoad 	= $$$GetConfig("on.workdirload","")
		set ..OnPull 			= $$$GetConfig("on.pull","")
		set ..OnReloadFiles 	= $$$GetConfig("on.reloadfiles","")
		set ..UseUDL 			= $$$GetConfig("udl",0)
		set ..UseXMLExtension 	= $$$GetConfig("xmlextension",1)
	
    	do ..LogUtils.Info("Working Directory: "_..Commands.WorkDir)
		$$$THROWONERROR(sc,..mnuStatus(""))
		
	} catch ex {
		set tSC = ex.AsStatus()
		do ##class(%System.Status).DecomposeStatus(tSC, .err, "d")
		
 		for i=1:1:err do ..LogUtils.Error(err(i))
		set tError="Error whilst Initialising. Check your configuration settings."  
		
	    set tSC=$$$ERROR($$$GeneralError,tError)
	    do ..LogUtils.Error(tError) 
	}
	do ..LogUtils.Info("========================================================="_$char(13))
	
	quit tSC
}

/// Adds an item to source control
Method mnuAdd(InternalName As %String, Description As %String) As %Status
{
	// export the class
	set extname		= ..ExternalName(InternalName)
	set sc 			= ..ExportToFile(InternalName, extname)
	
	set tSC			= ..Commands.Add(extname,.output)

	
	do ..LogUtils.InfoArray(.output)
	if $$$ISERR(tSC) quit tSC
	
	quit ..OnBeforeLoad(InternalName)
}

/// Unstages a file  - that is, no longer track this in source control
Method mnuUnstage(InternalName As %String) As %Status
{
	set extname		= ..ExternalName(InternalName)
	
	set tSC=..Commands.Reset(extname,.output,1)
	do ..LogUtils.InfoArray(.output)
	
	quit tSC
}

/// 
/// Reverts an item
Method mnuRevert(InternalName As %String) As %Status
{
	set tSC=..Commands.Checkout(..ExternalName(InternalName),.output)
	do ..LogUtils.InfoArray(.output)
	if $$$ISERR(tSC) quit tSC
	
	quit ..OnBeforeLoad(InternalName)
}

/// 
/// Returns source control log of an item
Method mnuLog(InternalName As %String) As %Status
{
	set tSC=..Commands.Log(..ExternalName(InternalName),.output)
	do ..LogUtils.InfoArray(.output)
	quit tSC
}

/// 
/// Returns source control log of an item
Method mnuDiff(InternalName As %String) As %Status
{
	set tSC=..Commands.Diff(..ExternalName(InternalName),.output)
	do ..LogUtils.InfoArray(.output)
	quit tSC
}

/// Get the source control status of an item
/// InternalName		- file to check (eg, package.sub-package.cls), or "" to check repository
Method mnuStatus(InternalName As %String) As %Status
{
	set tSC=..Commands.Status("",.statuscode,.statusdesc,.output)
	do ..LogUtils.InfoArray(.output)
	
	// if checking the repository, set IsGitInitialised to true or false.
	if output(1)["fatal: not a git repository" {
		set ..IsGitInitialised=0
	} else {
		set ..IsGitInitialised=1
	}
	quit tSC
}

/// 
/// Returns source control status of entire working directory
/// 
/// Adds all changes to stage
Method mnuAddAllChanges() As %Status
{
	set tSC=..Commands.Add("",.output)
	do ..LogUtils.InfoArray(.output)
	if $$$ISERR(tSC) quit tSC
	
	set tSC = ..mnuStatus("")
	quit tSC
}

/// 
/// Commits
Method mnuCommit(InternalName As %String, Description As %String, pAmend As %Boolean = 0) As %Status
{
 	// export the latest version
 	set tSC=..OnAfterSave(InternalName)
 	if $$$ISERR(tSC) quit tSC

 	// git commit
 	set tSC=..Commands.Commit(..ExternalName(InternalName), Description, .output, pAmend, 1)
 	do ..LogUtils.InfoArray(.output)
 	quit tSC
}

/// 
/// Creates a branch and then switch to it
Method mnuCreateAndSwitchToBranch(pBranch As %String) As %Status
{
	
	set tSC = ..NewBranch(pBranch)
	if $$$ISERR(tSC) quit tSC
	
	quit ..mnuSwitchToBranch(pBranch)
}

/// 
/// Switchs workspace to branch
Method mnuSwitchToBranch(pBranch As %String) As %Status
{
	// diff with new branch
	set tSC=..Commands.DiffStatus(pBranch, 1, .files,0)
	if $$$ISERR(tSC) quit tSC
	
	// switch branch
	set current=..Commands.GetCurrentBranch()
	set tSC=..Commands.Checkout("",pBranch,.output,1)
	do ..LogUtils.InfoArray(.output)
	if $$$ISERR(tSC) quit tSC
	
	// reload files
	do ..LogUtils.Info($c(13)_">Analyzing files after changing from """_current_""" to """_pBranch_"""")
	do ..ReloadFiles(.files, .updated, .deleted)
	do ..LogUtils.Info(">Completed.")
	
	quit tSC
}

/// 
/// Diffs current branch with other branch
Method mnuDiffWithBranch(pBranch As %String) As %Status
{
	set tSC=..Commands.DiffStat(pBranch, 0, .output)
	do ..LogUtils.Info(.output)
	quit tSC
}

/// 
/// Pushes local changes to origin
Method Push() As %Status
{
	set tSC=..Command.Push(.output,1)
	do ..LogUtils.Info(.output)
	quit tSC
}

/// 
/// Pulls fresh changes from origin to local
Method Pull(pDry As %Boolean = 0) As %Status
{
	// update remote origin info
	set tSC=..Command.RemoteUpdate("origin", .out1, 1)
	do ..LogUtils.Info(.out1)
	
	
	// get diff current..origin
	set current = ..Command.GetCurrentBranch()
	set tSC = ..Command.DiffStatus("origin"_"/"_current, 1, .out2, 1)
	do ..LogUtils.Info(.out2)
	
	
	if 'pDry {
		// pull
		set tSC=..Command.Pull(.out3, 1)
		do ..LogUtils.Info(.out3)

	
		// load changes into studio 
		do ..LogUtils.Info($c(13)_">Reloading diff with: origin"_"/"_current)
		do ..ReloadFiles(.out2, .updated, .deleted)
		do ..LogUtils.Info(">Completed.")
	}
	
	if $$$ISOK(tSC),..OnPull'=""{
		do ..LogUtils.Info($char(13)_">Calling on.pull callback: "_$listget(..OnPull,1)_":"_$listget(..OnPull,2))
		do ..LogUtils.Info(">result="_$classmethod($listget(..OnPull,1), $listget(..OnPull,2), updated, deleted))
	}
	
	quit tSC
}

/// 
/// Creates a new branch
Method NewBranch(pBranch As %String) As %Status
{
	set tSC=..Commands.Branch(pBranch,.output)
	do ..LogUtils.Info(.output)
	quit tSC
}

/// 
/// Reloads files passed <files> list:
/// Files marked as "D" will be deleted, rest will be reloaded
/// Each file entry should be like:
/// A path/file.xml
/// M path/file1.xml
/// D path/file2.xml
Method ReloadFiles(ByRef files, Output updated, Output deleted) [ Private ]
{
	set next="", updated="", deleted=""
	for {
		set next=$order(files(next))
		quit:next=""
		
		set line=files(next)
		set line=$tr(line,$c(9)," ")
		set line=$zstrip(line,"=W")
		
		set status=$p(line," ",1)
		set file=$p(line," ",2)
		
		set internalname=..InternalName(file)
		if internalname="" {
			do ..LogUtils.Info(">>Ignoring "_file)
		}
		elseif status'="D" {
			do ..LogUtils.Info(">>Loading "_internalname)
			set tSC=..OnBeforeLoad(internalname)
			set updated = updated_$lb(internalname)
		}
		elseif status="D" {
			do ..LogUtils.Info(">>Deleting "_internalname)
			set tSC=##class(%RoutineMgr).Delete(internalname)
			set tSC=..DeleteControlledItem(internalname)
			set deleted = deleted_$lb(internalname)
		}
	}
	
	// callback
	if ..OnReloadFiles'=""{
		do ..LogUtils.Info($char(13)_">Calling on.reloadfiles callback: "_$listget(..OnReloadFiles,1)_":"_$listget(..OnReloadFiles,2))
		do ..LogUtils.Info(">result="_$classmethod($listget(..OnReloadFiles,1), $listget(..OnReloadFiles,2), updated, deleted))
	}
}

/// 
/// Deletes a source controlled item
Method DeleteControlledItem(InternalName As %String) As %Status
{
	set extname = ..ExternalName(InternalName)
	do ..LogUtils.Info("Deleting file: "_extname)
	set ret = ##class(%File).Delete(extname)
		
	kill ^SourceControl(0,InternalName)
	kill ^SourceControl(1,InternalName)
	
	quit ret
}

/// 
/// Returns the internal name corresponding to an external file
Method InternalName(ExternalName As %String) As %String
{
 	// ignore files which are not under IRIS subdir
 	if ExternalName'[..Commands.IRISExportFolderPath quit ""
 	
 	// remove IRIS subdir name to calculate InternalName
 	set ExternalName = $replace(ExternalName,..Commands.IRISExportFolderName,"")
 	
 	set ext=$zconvert($piece(ExternalName,"/"),"U")
 	set left=$piece(ExternalName,"/",2,$length(ExternalName,"/"))
 	set name=$piece(left,".")
 	set result=$translate(name,"/",".")_"."_ext
 	quit result
}

/// 
/// Returns the external name (external file name) corresponding to a document element
/// Add Export Category sub-folder if defined for this file type.
Method ExternalName(InternalName As %String) As %String
{
	// check if it is a UserType (e.g. BPL, DTL, etc.)
	if ##class(%RoutineMgr).UserType(InternalName,.docclass,.doctype) {
		// check for a real abstract document subclass (or GetOther() may not work)
		if $classmethod(docclass,"%IsA","%Studio.AbstractDocument") {
			
			set actualName = $classmethod(docclass,"GetOther",InternalName)
			// the actualName is only valid if we get a single .cls as a result
			if actualName'[",",$zconvert($piece(actualName,".",$length(actualName,".")),"U")="CLS" {
				// we use what GetOther() gives us, eg: Demo.Loan.FindRateProcess.bpl becomes Demo.Loan.FindRateProcess.cls
				set InternalName = actualName
			}
		}
	}
	
 	set name=$piece(InternalName,".",1,$length(InternalName,".")-1)
 	set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
 	quit:name="" ""
 	
 	set filename=..ExportAddCategory(ext)_"/"_$translate(name,".","/")_$case(..UseXMLExtension, 1:".xml", :"."_ext)
 	quit ..Commands.IRISExportFolderPath_filename
}

/// Exports to external file
Method ExportToFile(InternalName As %String, Filename As %String) As %Status
{
	#define isUDLSupported ($system.Version.GetNumber()>=2016.2)
	
	#if $$$isUDLSupported
		// Caché/IRIS version supports exporting as UDL
		// UDL option enabled and file extension supports UDL, export as UDL
		set ext = $zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
		if ..UseUDL&&('$listfind(..#NOTUDLEXTENSIONS, ext)) {
			quit $system.OBJ.ExportUDL(InternalName, Filename, "-d /diffexport")
		}
	#else
		// Caché/IRIS does not support exporting as UDL.
		// UDL option enabled, log an error and continue to export as XML.
		if ..UseUDL {
			do ..LogUtils.Error("Server version "_$zv_" does not support exporting as UDL. Using XML instead...")
		}
	#endif
	
	// Default, export as XML.
	quit $system.OBJ.Export(InternalName, Filename, "-d /diffexport")
}

/// return subfolder category under which to export different 
/// items. If nto defined, use item type (extension, ie, 'cls', or 'mac')
Method ExportAddCategory(extension) As %String
{
	// value should not contain any leading slash.
	quit $$$GetConfigExportCategory(extension,extension)
}

/// Provides a normalized way to format InternalNames (that is, make uppercase extension)
ClassMethod NormalizeInternalName(InternalName As %String)
{
	set name=$piece(InternalName,".",1,$length(InternalName,".")-1)
 	set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"U")
 	quit name_"."_ext
}

/// Check if this type of document is supported for source control processing.
/// Returns if an item is supported or not
Method IsSupported(InternalName As %String) As %Status [ Private ]
{
	set ret=$$$OK
	
	set ntypes=$length(..#NOTSUPPORTEDTYPES,",")
	for i=1:1:ntypes {
		set type=$piece(..#NOTSUPPORTEDTYPES,",",i)
		if $zcvt(InternalName,"U")[type {
			set tError="Error: "_type_" items are not currently supported"
	    	set ret=$$$ERROR($$$GeneralError,tError)
	    	do ..LogUtils.Error(tError)
			quit
		}
	}
	
	quit ret
}

/// Returns status of an item 
Method GetStatus(InternalName As %String, ByRef IsInSourceControl As %Boolean, ByRef Editable As %Boolean, ByRef IsCheckedOut As %Boolean, ByRef IsAdded As %String) As %Status
{
 
 	quit:InternalName="" $$$OK
 	
 	set (statuscode,statusdesc)=""
 	set Editable=0,IsCheckedOut=0,UserCheckedOut=""
 	set extname=..ExternalName(InternalName)
 
 	set exists=##class(%File).Exists(extname)
 	if exists {
 		set tSC = ..Commands.Status(extname, .statuscode, .statusdesc, .output, 0)
 		if $$$ISERR(tSC) quit tSC
 	}
 	set IsInSourceControl=((exists)&&(statuscode'="?")&&(statuscode'=""))
 	set Editable=1
 	set IsCheckedOut=(statuscode="M")
 	set IsAdded=(statuscode="A")
 	quit $$$OK
}

/// 
/// ---- Event Callback functions ---------------------------------------------------------
/// Called before the item is saved to the database it is passed
/// a reference to the current temporary storage of this item so that it
/// can be modified before the save completes. If you quit with an error
/// value then it will abort the save.
Method OnBeforeSave(InternalName As %String, Location As %String = "", Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
    do ..LogUtils.Debug(..#PREFIX_" OnBeforeSave "_$Get(InternalName)_" "_$Get(Location)_" "_$Get(Object))
    
    #; Modify the document comment (for classes only)
    If $zcvt($Piece(InternalName,".",*),"U")="CLS" {
        Set @Location@(4)="Updated at "_$zdt($zts)
        If $Get(..Modified) {
            #; If the client wants to be notified of modifications, tell them
            Set ..Modified(InternalName)=1
        }
    }
    
    Quit $$$OK
}

/// This is called after the item has been saved to the database.
/// It may be passed a reference to the object representing the item
/// just saved. It can be use to export this documement to an external form for example.
/// 
/// Record in a database global (^SourceControl) the date/time of the exported document in the OS.
/// this will allow us to know if another copy is saved to the OS Folder, but not modified in the database.
/// Which happens then someone git pulls documents from a remote repository.
Method OnAfterSave(InternalName As %String, Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
    do ..LogUtils.Debug(..#PREFIX_" OnAfterSave "_$Get(InternalName)_" "_$Get(Object))
    
	set filename=..ExternalName(InternalName)
 	if filename="" Quit $$$OK

 	// if the timestamp of the item in the database has not changed then there is no point in saving it again
 	if ##class(%RoutineMgr).TS(InternalName)=$get(^SourceControl(1,InternalName)) Quit $$$OK

 	// call the export function
 	if (..IsInSourceControl(InternalName)) {
 		set tSC = ..ExportToFile(InternalName, filename)
 		if $$$ISOK(tSC) {
 			do ..LogUtils.Info("Exported '"_InternalName_"' to file '"_filename_"'")
 			set ^SourceControl(0,InternalName)=##class(%File).GetFileDateModified(filename)
 			set ^SourceControl(1,InternalName)=##class(%RoutineMgr).TS(InternalName)
		} else {
		do ##class(%System.Status).DecomposeStatus(tSC, .err, "d")
		for i=1:1:err do ..LogUtils.Error(err(i))
	 	}
	 
	}
 	quit $$$OK
}

/// This is called before the actual load of of a studio document is done, into the IDE,.
/// to load the item from an external format.
/// 
Method OnBeforeLoad(InternalName As %String) As %Status
{
	do ..LogUtils.Debug(..#PREFIX_" OnBeforeLoad "_$Get(InternalName))
 	
 	set InternalName = ..NormalizeInternalName(InternalName)
 	set extname = ..ExternalName(InternalName)
 	quit:extname="" $$$OK
 
	// skip the import if not in source control
	if '..IsInSourceControl(InternalName) {
	 do ..LogUtils.Info(InternalName_" is not in source control, skipping import") 
	 quit $$$OK
	}
 
	// if the timestamp on the file is the same as the last time it was imported 
	// then there is nothing to do as it is already up to date
	if ##class(%File).GetFileDateModified(extname) = $get(^SourceControl(0,InternalName)) quit $$$OK
	
	// call the function to do the import  - External file is newer than database version
	set tSC=$system.OBJ.Load(extname,"-l-d")
	if $$$ISOK(tSC) {
		do ..LogUtils.Info("Imported '"_InternalName_"' from file '"_extname_"'")
		set ^SourceControl(0,InternalName)=##class(%File).GetFileDateModified(extname)
		set ^SourceControl(1,InternalName)=##class(%RoutineMgr).TS(InternalName)
	} else {
		do ##class(%System.Status).DecomposeStatus(tSC, .err, "d")
		for i=1:1:err do ..LogUtils.Error(err(i))
	}
	
	quit tSC
}

/// 
/// ----- TODO - Implement menu activity below ---------
/// 
/// This code execute as each menu option is being displayed to the user. This is the place where you can
/// (a) display a menu as disabled
/// (b) ommit showing a menu altogether
/// (c) re-word, or add detail to a menu item.
/// 
/// MenuName 		= <topLevel>,<subLevel>
/// InternalName	= full internal class name includnig extension
/// Enabled		 	= ByRef, set to 0 to show menu item as disabled
/// Display 		= Set this to re-word the menu item caption
/// 
Method OnMenuItem(MenuName As %String, InternalName As %String, SelectedText As %String, ByRef Enabled As %Boolean, ByRef DisplayName As %String) As %Status
{
	
    do ..LogUtils.Debug(..#PREFIX_" OnMenuItem "_$Get(MenuName)_" "_$Get(InternalName)_" "_$Get(SelectedText)_" "_$Get(Enabled)_" "_$Get(DisplayName))
	set tSC=$$$OK
	
	try {
		set menu=$piece(MenuName,","),name=$piece(MenuName,",",2)
 		
 		if $e(name)="*" set Enabled=0 quit
 		
		if menu="%SourceMenu",name'="",name'="--------------" {
			
			// '%SourceMenu' Menu items 			
			if name="Initialise Repository",'..IsGitInitialised {
			 	set Enabled=1
			} elseif name="Initialise Repository",..IsGitInitialised {
				set Enabled=-1
				quit
			}
			
			// no current document is open
			if ((InternalName="") && ((name="Add")||(name="Unstage")) ) {
				set Enabled=0
				quit
			}		
				
			// get file source control status only once for all MenuItems
			if name=..#FIRSTMENUITEM  {
					$$$THROWONERROR(sc, ..GetStatus(InternalName,.iscontrolled,.iseditable,.ischeckedout,.isadded))
					set ..IsControlled = iscontrolled
					set ..IsEditable = iseditable
					set ..IsCheckedOut = ischeckedout
					set ..IsAdded = isadded

			} 
						
			// disable menu items depending on file status
			if name="Add" {
				set:((..IsControlled)) Enabled=0
			} elseif (name="Unstage") {
				set:(('..IsControlled)||(..IsCheckedOut)||('..IsAdded)) Enabled=0
			} elseif (name="Revert changes") {
				set:(('..IsControlled)||('..IsCheckedOut)) Enabled=0
			} elseif (name="Log")||(name="Diff") {
				set:(('..IsControlled)) Enabled=0
			}
			
			// display current branch name
			if name="Status" {
				set DisplayName = "Status ["_..Commands.GetCurrentBranch()_"]"
			}
		}

	} catch errObj {
		set ret = errObj.AsStatus()
		write !,"OnMenuItem() Error: ",##class(%SYSTEM.Status).GetErrorText(ret)
	}
	
	/// Add OnMenuItem logic for other custom menus here.
	/// if menu=""... {}
			 
    Quit $$$OK
}

/// This method is called when a user choose a menu option, but prior to executing any logic. It's the opportunity to 
/// present further prompts.
/// Some menu options may require a further Dialog, like 'get comments for the Checkin/Commit of code.
/// This is where you prompt this extra behavior, by specifying the output properties of
/// Action, Target, Msg and Reload.
/// 
Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
	set Action=0,Target="",Msg="",Reload=0
	set menu=$piece(Name,","),name=$piece(Name,",",2)
	
	if menu="%SourceMenu"!(menu="%SourceContext") {
		if ((name="Revert changes")||(name="Unstage")) {
			set Action=1
			set Target="File """_InternalName_""": Are you sure you want to "_name_"?"
		}
		elseif (name="Workdir - Load files")||(name="Abort merge") {
			set Action=1
			set Target="WARNING: Are you sure you want to """_name_"""?"
		}
		elseif (name="Commit...")||(name="Amend commit...") {
			set Action=7
			set Target="WARNING: Committing ALL changes. Enter Check-in message here"
		}
		elseif ((name="Create and Switch to Branch...")||(name="Switch to Branch...")||(name="Diff with Branch...")||(name="Merge with...")) {
			set Action=7
			set Target=$piece(name,"...")_". Enter branch name:"
		} elseif (name="CSP Test") {
			set Action=2
			set Target="/csp/healthshare/sctests/Studio.SourceControl.GITSetup.cls"
		
		} else {
			quit ..AfterUserAction(Type,Name,InternalName,1,,.Reload)
		}
	}
	
	// Add UserActions for other menus here
	/// if menu=""... {}

	quit $$$OK
}

/// This method is called after the method UserAction.
/// It is the method that execute a menu option, and includes other information, that might have been captured as 
/// part of the intermediary login primed by UserAction()
/// 
Method AfterUserAction(Type As %Integer, Name As %String, InternalName As %String, Answer As %Integer, Msg As %String = "", ByRef Reload As %Boolean) As %Status
{
	set Reload=0
	
	set menu=$piece(Name,","),name=$piece(Name,",",2)
	if menu="%SourceMenu",name'="--------------" {
		
		set issupported=..IsSupported(InternalName)	if $$$ISERR(issupported) quit issupported
		
		if Answer'=1 quit $$$OK
		
		if ((name="Add")||(name="Stage")) 			quit ..mnuAdd(InternalName,Msg)
		if name="Unstage" 							quit ..mnuUnstage(InternalName)
		if name="Revert changes" 					quit ..mnuRevert(InternalName)
		if name="Log" 								quit ..mnuLog(InternalName)
		if name="Diff" 								quit ..mnuDiff(InternalName)
		
		if name="Status" 							quit ..mnuStatus(InternalName)
		if name="Add All Changes" 					quit ..mnuAddAllChanges()
		if name="Commit..." 						quit ..mnuCommit(InternalName,Msg)
		;if name="Amend commit..." 					quit ..Commit(InternalName,Msg,1)
		
		if name="Switch to Branch..." 				quit ..mnuSwitchToBranch(Msg)
		if name="Create and Switch to Branch..." 	quit ..mnuCreateAndSwitchToBranch(Msg)
		if name="Diff with Branch..." 				quit ..mnuDiffWithBranch(Msg)
		
		;if name="List Branches" 					quit ..ListBranches(Msg)
		
		;if name="Merge with..." 					quit ..Merge(Msg)
		;if name="Abort merge" 						quit ..AbortMerge()
		;if name="Load status changes" 				quit ..LoadStatusChanges()
		
		;if name="Diff with origin" 				quit ..Pull(1)
		;if name="Pull origin->local" 				quit ..Pull()
		;if	name="Push local->origin" 				quit ..Push()
		
		;if name="Workdir - Load files" 			quit ..WorkdirLoadFiles(..Commands.WorkDir)
		
		;if name="Initialise Repository" 			quit ..InitialiseRepository(..Commands.WorkDir)
	}
		
	quit $$$OK
}

}

