Include Studio.SourceControl

/// Updated at 02/04/2021 21:57:12
Class Studio.SourceControl.v1.SourceControl Extends %Studio.SourceControl.Base
{

/// Studio menu options.
/// 
XData Menu
{
<MenuBase>
<Menu Name="%SourceMenu" Type="0">
<MenuItem Name="Initialise Repository" Save="100"/>
<MenuItem Separator="1" Name="--------------"/>
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
<MenuItem Name="Switch to Branch..."/>
<MenuItem Name="Create and Switch to Branch..."/>
<MenuItem Name="Diff with Branch..."/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="Merge with..."/>
<MenuItem Name="Abort merge"/>
<MenuItem Name="Load status changes"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="Diff with origin"/>
<MenuItem Name="Pull origin->local"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="Push local->origin"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="Workdir - Load files"/>
<MenuItem Separator="1" Name="--------------"/>
<MenuItem Name="CSP Test"/>
</Menu>
<Menu Name="%SourceContext" Type="1">
<MenuItem Name="contextMenu-Add" Save="100"/>
<MenuItem Name="contextMenu-Unstage"/>
<MenuItem Name="contextMenu-Revert changes" Save="100"/>
<MenuItem Name="contextMenu-Log"/>
<MenuItem Name="contextMenu-Diff"/>
</Menu>


</MenuBase>
}

/// This aids in identifying the hook output amongst other console output
Parameter PREFIX = "*** Atelier Source Control Hook *** ";

Method OnMenuItem(MenuName As %String, InternalName As %String, SelectedText As %String, ByRef Enabled As %Boolean, ByRef DisplayName As %String) As %Status
{
    Write !,..#PREFIX,"OnMenuItem ",$Get(MenuName)," ",$Get(InternalName)," ",$Get(SelectedText)," ",$Get(Enabled)," ",$Get(DisplayName),!
    
    Set menu=$piece(MenuName,","),name=$piece(MenuName,",",2) 
    If menu'="%SourceMenu",menu'="%SourceContext" Quit $$$OK
        
    If InternalName="" Quit $$$OK
    Set sc=..GetStatus(InternalName,.isinsourcecontrol,.editable,.ischeckedout)
    Set isinsourcecontrol=+$get(isinsourcecontrol),editable=+$get(editable),ischeckedout=+$get(ischeckedout)
    If $$$ISERR(sc) Quit sc
    If name="%CheckOut" {
        If ischeckedout||('isinsourcecontrol) Set Enabled=0
    } ElseIf name="%CheckIn" {
        If 'isinsourcecontrol||('ischeckedout) Set Enabled=0
    } ElseIf name="%UndoCheckout" {
        If 'isinsourcecontrol||('ischeckedout) Set Enabled=0
    } ElseIf name="%GetLatest" {
        If ischeckedout||('isinsourcecontrol) Set Enabled=0
    } ElseIf name="%AddToSourceControl" {
        If isinsourcecontrol||(InternalName="") Set Enabled=0
    }
    Quit $$$OK
}

/// 
/// Handles user selected action from menu
Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
	set Action=0,Target="",Msg="",Reload=0
	set menu=$piece(Name,","),name=$piece(Name,",",2)
	
	if menu="Source Control" {
		if ((name="Revert changes")||(name="Unstage")) {
			set Action=1
			set Target="File """_InternalName_""". Are you sure you want to """_name_"""?"
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
		
		}
		else {
			quit ..AfterUserAction(Type,Name,InternalName,1,,.Reload)
		}
	}
	quit $$$OK
}

/*
/// 
/// Perfoms the selected action itself
Method AfterUserAction(Type As %Integer, Name As %String, InternalName As %String, Answer As %Integer, Msg As %String = "", ByRef Reload As %Boolean) As %Status
{
	set Reload=0
	
	set menu=$piece(Name,","),name=$piece(Name,",",2)
	if menu="Source Control",name'="--------------" {
		
		set issupported=..IsSupported(InternalName)	if $$$ISERR(issupported) quit issupported
		
		if Answer'=1 quit $$$OK
		
		if ((name="Add")||(name="Stage")) 			quit ..Add(InternalName,Msg)
		if name="Unstage" 							quit ..Unstage(InternalName)
		if name="Revert changes" 					quit ..Revert(InternalName)
		if name="Log" 								quit ..Log(InternalName)
		if name="Diff" 								quit ..Diff(InternalName)
		
		if name="Status" 							quit ..Status(InternalName)
		if name="Add All Changes" 					quit ..AddAllChanges()
		if name="Commit..." 						quit ..Commit(InternalName,Msg)
		if name="Amend commit..." 					quit ..Commit(InternalName,Msg,1)
		
		if name="Switch to Branch..." 				quit ..SwitchToBranch(Msg)
		if name="Create and Switch to Branch..." 	quit ..CreateAndSwitchToBranch(Msg)
		if name="Diff with Branch..." 				quit ..DiffWithBranch(Msg)
		
		if name="List Branches" 					quit ..ListBranches(Msg)
		
		if name="Merge with..." 					quit ..Merge(Msg)
		if name="Abort merge" 						quit ..AbortMerge()
		if name="Load status changes" 				quit ..LoadStatusChanges()
		
		if name="Diff with origin" 					quit ..Pull(1)
		if name="Pull origin->local" 				quit ..Pull()
		if name="Push local->origin" 				quit ..Push()
		
		if name="Workdir - Load files" 				quit ..WorkdirLoadFiles(..Command.WorkDir)
		
		if name="Initialise Repository" 			quit ..InitialiseRepository(..Command.WorkDir)
	}
		
	quit $$$OK
}
*/
/// Check this routine/class/csp file into source control.
Method CheckIn(InternalName As %String, Description As %String = "") As %Status
{
    Write !,..#PREFIX,"CheckIn ",$Get(InternalName)," ",$Get(Description),!
    Quit $$$OK
}

/// Check this routine/class/csp file out of source control.
Method CheckOut(InternalName As %String, Description As %String = "") As %Status
{
    Write !,..#PREFIX,"CheckOut ",$Get(InternalName)," ",$Get(Description),!
    Quit $$$OK
}

/// Undo the checkout of this item.
Method UndoCheckout(InternalName As %String) As %Status
{
    Write !,..#PREFIX,"UndoCheckOut ",$Get(InternalName),!
    Quit $$$OK
}

/// Called to add this item to source control
Method AddToSourceControl(InternalName As %String, Description As %String = "") As %Status
{
   Write !,..#PREFIX,"AddToSourceControl ",$Get(InternalName)," ",$Get(Description),!
    Quit $$$OK
}

/// Called to delete this item from source control
Method RemoveFromSourceControl(InternalName As %String, Description As %String = "") As %Status
{
    Write !,..#PREFIX,"RemoveFromSourceControl ",$Get(InternalName)," ",$Get(Description),!
    Quit $$$OK
}

/// Get the latest version of this file from source control.
Method GetLatest(InternalName As %String) As %Status
{
    Write !,..#PREFIX,"GetLatest ",$Get(InternalName),!
    Quit $$$OK
}

/// Called before the item is saved to the database it is passed
/// a reference to the current temporary storage of this item so that it
/// can be modified before the save completes. If you quit with an error
/// value then it will abort the save.
Method OnBeforeSave(InternalName As %String, Location As %String = "", Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
    Write !,..#PREFIX,"OnBeforeSave ",$Get(InternalName)," ",$Get(Location)," ",$Get(Object),!
    
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

/// Called in the activated source control class after we have compiled all the classes but before we exit.
/// Note that this is a class method and it does not require the source
/// control class to be instanciated in order for it to be called. By default it will call the <method>OnAfterClassCompile</method>
/// if there is a source control class instanciated, but you can override this to do whatever you require.
/// <var>List</var> is a subscripted array of items that were compiled. <var>Status</var> is the current compile return
/// error %Status, so the callback can check if there was any error in compiling the list of classes.
ClassMethod OnAfterAllClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String, Status As %Status) As %Status
{
    Write !,..#PREFIX,"OnAfterAllClassCompile ",$Get(List)," ",$Get(Level)," ",$Get(qstruct)," ",$Get(Status),!
    Set sc=$$$OK
    If $isobject($get(%SourceControl)) {
        Set tmp=%SourceControl New %SourceControl
        Set sc=tmp.OnAfterClassCompile(.List,Level,.qstruct,.Status)
    }
    Quit sc
}

/// Called in the class compiler after we have compiled all the classes before we exit
/// <var>List</var> is a subscripted array of items that were compiled. <var>Status</var> is the current compile return
/// error %Status, so the callback can check if there was any error in compiling the list of classes.
Method OnAfterClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String, Status As %Status) As %Status
{
    Write !,..#PREFIX,"OnAfterClassCompile ",$Get(List)," ",$Get(Level)," ",$Get(qstruct)," ",$Get(Status),!
    Quit $$$OK
}

/// Called after the compile of the item is done.
Method OnAfterCompile(InternalName As %String) As %Status
{
    Write !,..#PREFIX,"OnAfterCompile ",$Get(InternalName),!
    Quit $$$OK
}

/// Called after an item is deleted.
Method OnAfterDelete(InternalName As %String) As %Status
{
    Write !,..#PREFIX,"OnAfterDelete ",$Get(InternalName),!
    Quit $$$OK
}

/// This is called after the item is loaded but before it is sent to Studio
/// so you have a chance to modify this copy before it appears in the editor.
/// It is passed a reference to the object that represents this item so it
/// can be modified before Studio reads this information.
Method OnAfterLoad(InternalName As %String, Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
    Write !,..#PREFIX,"OnAfterLoad ",$Get(InternalName)," ",$Get(Object),!
    Quit $$$OK
}

/// This is called after the item has been saved to the database.
/// It may be passed a reference to the object representing the item
/// just saved. It can be use to export this documement to an external form for example.
Method OnAfterSave(InternalName As %String, Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
    Write !,..#PREFIX,"OnAfterSave ",$Get(InternalName)," ",$Get(Object),!
    Quit $$$OK
}

/// This is called if you compile a class and the compilation updates the classes storage.
/// It is called after the storage has been updated so you can determine how to deal with this
/// change in the class. The <var>Location</var> is the global reference to the class definition that was changed.
Method OnAfterStorage(InternalName As %String, Location As %String = "") As %Status
{
    Write !,..#PREFIX,"OnAfterStorage ",$Get(InternalName)," ",$Get(Location),!
    Quit $$$OK
}

/// Called in the activated source control class before starting a compile after we have resolved the list of classes
/// but before we have started the compile itself. Note that this is a class method and it does not require the source
/// control class to be instanciated in order for it to be called. By default it will call the <method>OnBeforeClassCompile</method>
/// if there is a source control class instanciated, but you can override this to do whatever you require.
/// Returning an error here will abort the compile.
/// <var>List</var> is a subscripted array of items that will be compiled.
ClassMethod OnBeforeAllClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String) As %Status
{
    Write !,..#PREFIX,"OnBeforeAllClassCompile ",$Get(List)," ",$Get(Level)," ",$get(qstruct),!
    Set sc=$$$OK
    If $isobject($get(%SourceControl)) {
        Set tmp=%SourceControl New %SourceControl
        Set sc=tmp.OnBeforeClassCompile(.List,Level,.qstruct)
    }
    Quit sc
}

/// Called in the class compiler after we have resolved the list of classes to be compiled but
/// before we have started the compile itself.
/// <var>List</var> is a subscripted array of items that will be compiled.
Method OnBeforeClassCompile(List As %String, Level As %Integer, ByRef qstruct As %String) As %Status
{
    Write !,..#PREFIX,"OnBeforeClassCompile ",$Get(List)," ",$Get(Level)," ",$get(qstruct),!
    Quit $$$OK
}

/// Called before the compile of the item is done.
/// It is passed a qstruct which can be inspected and modified.
Method OnBeforeCompile(InternalName As %String, ByRef qstruct As %String) As %Status
{
    Write !,..#PREFIX,"OnBeforeCompile ",$Get(InternalName)," ",$get(qstruct),!
    Quit $$$OK
}

/// Called before an item is deleted. Returning an error code prevents the delete from occurring.
Method OnBeforeDelete(InternalName As %String) As %Status
{
   Write !,..#PREFIX,"OnBeforeDelete ",$Get(InternalName),!
    Quit $$$OK
}

/// This is called before the actual load of data to give the chance
/// to load the item from an external format.
Method OnBeforeLoad(InternalName As %String) As %Status
{
    Write !,..#PREFIX,"OnBeforeLoad ",$Get(InternalName),!
    Quit $$$OK
}

/// Called before Studio checks for the timestamp of an item.
Method OnBeforeTimestamp(InternalName As %String)
{
    Write !,..#PREFIX,"OnBeforeTimeStamp ",$Get(InternalName),!
    Quit
}

/// Callback invoked when the portal-based Source Control hooks instantiate the source control class.
/// Operations that occur in this callback should be lightweight as the source control class needs to 
/// be instantiated afresh every time a source control action is performed.
Method OnPortalCreate(pUserData As %ZEN.proxyObject = "") As %Status [ CodeMode = objectgenerator ]
{
 
    If (%compiledclass.Name = "%Studio.SourceControl.Base") {
        Do %code.WriteLine($char(9)_"Quit $$$OK")
        Quit $$$OK
    }
    // Ensure that legacy Ensemble OnEnsembleCreate() method is called if it exists
    Set tDone = 0
    Set tOnEnsembleCreate = %compiledclass.Methods.FindObjectId(%compiledclass.Name _ "||OnEnsembleCreate")
    If (tOnEnsembleCreate) {
        Set tMethod = %compiledclass.Methods.GetAt(tOnEnsembleCreate)
        If ($IsObject(tMethod)) {
            Do %code.WriteLine($char(9)_"Quit ..OnEnsembleCreate(pUserData)")
            Set tDone = 1
        }
    }
    If ('tDone) {
        Do %code.WriteLine($char(9)_"Quit $$$OK")
    }
    Quit $$$OK
}

}

