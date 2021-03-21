/* 	-- Make Folder validations as follows:  All FOLDER fields must end in "\" to distinguis from filenames.
	ADD note/option to remain 'in-sync with' any relevant VSCode setting.json changes.
	Prompt/save for AuthorName and AuthorEmail.
	Ensure 'FINISH" button only available of all all validation is possible.
	Fix the ending of the Wizard - Last page should display entire tree, all Settings and Confirm setup.
	Fix ending - upon setup, 'Cancel' button should become close.
	Fix this window UI - it should not be a 'Studio Template', (and should not say this in the title) - remove SuperServer and make basic CSP
	Validate all paths (workPath, Root FolderPAth, etc) have the right amount of starting/endingn "\".
	Fix bug if .vscode/settings.json exist, but export settings are beingn retreived from USER (not WORKSPACE) setting.
	Add scenario if .vscode/settings.json does NOT exist, but aLL export settings are being retreived from USER (not WORKSPACE) setting.
	If .vscode/settings exists, but, objectscript.export folder is undefined, assume it is "/src" (the default).
	Remove all references and code of a Studio 'TEMPLATE'.
	Deal with this setup form being invoked when ^GITConfig already exists in this namespace
	Allow for {namespace} and {username} in OSRootFolderExport.
	Ensure this class is callable from GIT SourceControl Studio class, (and hidden once setup, unless we can handle edits nicely)
	
*/

Include Studio.SourceControl

/// #TODO
/// ###############
/// Studio Template: New ZEN Form
Class Studio.SourceControl.GITSetup Extends %ZEN.Template.studioTemplate
{

Parameter TEMPLATENAME = "IRIS - GIT Setup";

Parameter TEMPLATETITLE = "GIT integration Setup for IRIS Studio";

Parameter TEMPLATEDESCRIPTION = "This wizard gathers the information needed to setup IRIS Namespaces and working folders to enable integration with GIT and GIT Remote repositories";

Parameter TEMPLATETYPE = "cls";

Parameter TEMPLATEMODE = "addin";

/// What type of template.
Parameter TEMPLATEGROUP = "Zen";

/// Domain used for localization.
Parameter DOMAIN = "%ZEN";

/// DOCBOOK Topic Id that offers help for this template.
Parameter HELPID;

Property exportTypes As %String [ InitialExpression = ",*.cls,*.mac,*.int,*.inc,*.int,*.mvb,*.mvi,*.bas,*.csp,*.csr,*.rul,*.dfi,*.lut,*.hl7,*.x12,*.ast,*.api,*.xml, *.js, *.css, *.xsl *.xsd" ];

Property folderDelimeter As %String [ InitialExpression = "\" ];

Property OScriptRootFolderDefault As %String [ InitialExpression = "src\" ];

/// This is the configuration settings ID. By default, this is currently hardcoded to '0', meaning all users
/// connecting to this namespace will utilise one common configuration for integrating with git.
/// Concievable, however, this can be extended so that different users could define their own configuration, however, this has not 
/// been implemented.
Property ConfigID As %String [ InitialExpression = "0" ];

/// Users must have %Development:USE to access any Studio templates.
Parameter RESOURCE = "%Development:USE";

/// Do not use AutoLogout logic for template pages.
Parameter AUTOLOGOUT = 0;

/// If auto-switch namespace to whatever $NAMESPACE is passed in
Parameter AUTONS = 1;

/// If this is true then even if this template is tied to a specific namespace it
/// will be available in any namespace and it will be up to the template to make sure
/// it looks for any specific data in the target namespace.
Parameter GLOBALTEMPLATE As BOOLEAN = 1;

/*
/// This projection is used to keep track of when this page is
/// compiled or uncompiled. In this case, this notifies the
/// Studio Template Manager about the existence of this template.
Projection Template As %ZEN.Template.TemplateProjection;

/// Current project within Studio.
Property Project As %ZEN.Datatype.string(ZENURL = "Project");

/// Name of current document within Studio.
Property DocumentName As %ZEN.Datatype.string(ZENURL = "Name");

/// Current selected text within Studio.
Property SelectedText As %ZEN.Datatype.string(ZENURL = "SelectedText");
*/
/// Current namespace within Studio.
Property Namespace As %ZEN.Datatype.string(ZENURL = "Namespace");

/// Current user within Studio.
Property User As %ZEN.Datatype.string(ZENURL = "User");

/*
/// Current language within Studio (e.g., "cache").
Property Language As %ZEN.Datatype.string(ZENURL = "Language");

/// Namespace of current document within Studio.
Property DocumentNamespace As %ZEN.Datatype.string(ZENURL = "DocumentNamespace");
*/
/// DocBook topic id used to show help for this template.
Property helpId As %ZEN.Datatype.string [ InitialExpression = {..#HELPID} ];

XData CSS3Style
{
<style type="text/css">
body {
	background: #E0E0E0;
	font-family: arial, sans-serif;
	padding: 0px;
	margin: 0px;
}

.zenLabel {
	color: #404040;
	padding-left: 4px;
	font-size: 0.8em;
	vertical-align: middle;
}

.zenRequired {
	color: darkblue;
	padding-left: 4px;
	font-size: 0.8em;
	vertical-align: middle;
}

.hintText {
	font-size: 0.8em;
	vertical-align: middle;
	color: #808080;
}

#header {
	position: relative;
}

/* the height of the body will be adjusted on the client */
#body {
	background: none;
	padding: 0px;
	overflow: auto;
}

/* this must have 0 padding or sizing logic will fail */
#footer {
	position: absolute;
	bottom: 0;

	color: #404040;
	background: rgb(232,231,226);
	background-image: none;
	width: 100%;
	padding: 0px;
	border-top: 1px solid gray;
}

/* nested group lets us define some padding */
#buttonHolder {
	padding: 5px;
	margin: 0px;
}

#desc,#desc2 {
	padding: 0px;
	padding-top: 3px;
	padding-bottom: 3px;
	margin: 0px;
	margin-bottom: 5px;
	line-height: 120%;
	font-size: 0.8em;
}

.stdTitle {
	color: white;
	background: rgb(53,107,141);
	background-image: none;
	width: 100%;
	padding: 0px;
	border-bottom: 1px solid gray;
	font-size: 1.4em;
	font-family: arial;
	text-align: center;
	white-space: nowrap;
}

/* UserName etc. */
.stdTitleInfo {
	color: black;
	width: 100%;
	padding: 0px;
	font-family: arial;
	text-align: left;
	white-space: nowrap;
}

.stdTitleInfo td {
	color: black;
	padding-left: 5px;
	padding-right: 10px;
	font-size: 8pt;
	font-weight: bold;
	text-align: left;
	white-space: nowrap;
}

.stdTitleInfo th {
	color: white;
	padding: 0px;
	font-size: 8pt;
	font-weight: normal;
	text-align: right;
	white-space: nowrap;
}

/* buttons in footer */
#btnFinish input,#btnCancel input,#btnBack input,#btnNext input,#btnHelp input{
	width: 6.0em;
}
/* command button styles */
.commandButton {
	background: rgb(53,107,141);
	color: #E0E0E0;
	text-decoration: none;
	padding: 3px;
	padding-left: 10px;
	padding-right: 10px;
	border-radius: 5px;
 	border-top: 1px solid lightgray;
    border-left: 1px solid lightgray;
    border-right: 2px solid gray;
    border-bottom: 2px solid gray;
}

.commandButtonDisabled {
	background: white;
	text-decoration: none;
	padding: 3px;
	padding-left: 10px;
	padding-right: 10px;
	border-radius: 5px;
}

#btnBack input:hover,
#btnNext input:hover,
#btnFinish input:hover,
#btnCancel input:hover,
#btnHelp input:hover,
.commandButton:hover {
	background: rgb(53,107,141);
	color: white;
	background-image: url(portal/button_hover.png);
	background-repeat: repeat-x;
}


	#dtOScriptCategoriesW {
	    border-color: darkgrey;
	    border-left-style: double;
	    padding: 10px;
	}

	.middleVAlign {
		vertical-align: middle;
		font-size: 0.8em;
	}

	div.comboboxDropDown {
		padding-left:5px;
	}

	div.deleteXCategory {
		padding-left:5px;
	}

	#desc1,#desc2,#desc3 {
		padding: 0px;
		padding-top: 3px;
		padding-bottom: 3px;
		margin: 0px;
		margin-bottom: 5px;
		line-height: 120%;
		font-size: 0.8em;
	}


</style>
}

/// The standard template has three main divs: header,body, and footer.
/// Subclasses typically place their content within the body div (pane).
XData Style
{
<style type="text/css">
body {
	background: #E0E0E0;
	font-family: arial, sans-serif;
	padding: 0px;
	margin: 0px;
}

.zenLabel {
	color: #404040;
	padding-left: 4px;
	font-size: 0.8em;
	vertical-align: middle;
}

.zenRequired {
	color: darkblue;
	padding-left: 4px;
	font-size: 0.8em;
	vertical-align: middle;
}

.hintText {
	font-size: 0.8em;
	vertical-align: middle;
	color: #808080;
}

#header {
	position: relative;
}

/* the height of the body will be adjusted on the client */
#body {
	background: none;
	padding: 0px;
	overflow: auto;
}

/* this must have 0 padding or sizing logic will fail */
#footer {
	position: absolute;
	bottom: 0;

	color: #404040;
	background: rgb(232,231,226);
	background-image: none;
	width: 100%;
	padding: 0px;
	border-top: 1px solid gray;
}

/* nested group lets us define some padding */
#buttonHolder {
	padding: 5px;
	margin: 0px;
}

#desc,#desc2 {
	padding: 0px;
	padding-top: 3px;
	padding-bottom: 3px;
	margin: 0px;
	margin-bottom: 5px;
	line-height: 120%;
	font-size: 0.8em;
}

.stdTitle {
	color: white;
	background: rgb(53,107,141);
	background-image: none;
	width: 100%;
	padding: 0px;
	border-bottom: 1px solid gray;
	font-size: 1.4em;
	font-family: arial;
	text-align: center;
	white-space: nowrap;
}

/* UserName etc. */
.stdTitleInfo {
	color: black;
	width: 100%;
	padding: 0px;
	font-family: arial;
	text-align: left;
	white-space: nowrap;
}

.stdTitleInfo td {
	color: black;
	padding-left: 5px;
	padding-right: 10px;
	font-size: 8pt;
	font-weight: bold;
	text-align: left;
	white-space: nowrap;
}

.stdTitleInfo th {
	color: white;
	padding: 0px;
	font-size: 8pt;
	font-weight: normal;
	text-align: right;
	white-space: nowrap;
}

/* buttons in footer */
#btnFinish input,#btnCancel input,#btnBack input,#btnNext input,#btnHelp input{
	width: 6.0em;
}
/* command button styles */
.commandButton {
	background: rgb(53,107,141);
	color: #E0E0E0;
	text-decoration: none;
	padding: 3px;
	padding-left: 10px;
	padding-right: 10px;
	-moz-border-radius: 5px;
	border-radius: 5px;
 	border-top: 1px solid lightgray;
    border-left: 1px solid lightgray;
    border-right: 2px solid gray;
    border-bottom: 2px solid gray;
}

.commandButtonDisabled {
	background: white;
	text-decoration: none;
	padding: 3px;
	padding-left: 10px;
	padding-right: 10px;
	-moz-border-radius: 5px;
}

#btnBack input:hover,
#btnNext input:hover,
#btnFinish input:hover,
#btnCancel input:hover,
#btnHelp input:hover,
.commandButton:hover {
	background: rgb(53,107,141);
	color: white;
	background-image: url(portal/button_hover.png);
	background-repeat: repeat-x;
}
</style>
}

/// Contents of standard template page;
/// Subclasses can override this if they wish or
/// (more typically) implement the "body" pane with the desired content.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" >
<html id="header" OnDrawContent="%DrawTitle" />
<form id="templateForm" groupStyle=""
onvalidate="return zenPage.formValidationHandler();">
<hidden id="templateFinal" name="$FINAL" value="0" />
<pane paneName="templateBody" id="body"/>
</form>

<hgroup id="footer" width="100%" cellAlign="right">
<hgroup id="buttonHolder" cellAlign="right">
<button id="btnBack" controlClass="commandButton" caption="Back" onclick="zenPage.previousPage();" hidden="true"/>
<spacer width="5" />
<button id="btnNext" controlClass="commandButton" caption="Next" onclick="zenPage.nextPage();" hidden="true"/>
<spacer width="15" />
<button id="btnFinish" controlClass="commandButton" caption="Finish" onclick="zenPage.finishTemplate();" />
<spacer width="5" />
<button id="btnCancel" controlClass="commandButton" caption="Cancel" onclick="zenPage.cancelTemplate();" />
<spacer width="15" />
<button id="btnHelp" controlClass="commandButton" caption="Help" onclick="zenPage.showHelp();" />
<spacer width="10" />
</hgroup>
</hgroup>
</page>
}

XData templateBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane id="body">
<tabGroup id="tabGroup">
<tab>
<vgroup labelPosition="left" cellStyle="padding: 2px; padding-left: 5px; padding-right: 5px;">
<html id="desc1" OnDrawContent="%GetDescHTML1"/>

<text label="Workspace folder :" 
	id="txWorkDir"
	name="WorkDir"
	size="40"
	required="true"
	labelClass="zenRequired"
	title="Root workspace folder where Studio documents will be saved to." 
	 onchange="zenPage.updateState();"/> 
</vgroup>
</tab>

<tab>
<vgroup labelPosition="left" cellStyle="padding: 2px; padding-left: 5px; padding-right: 5px;">
<html id="desc2" OnDrawContent="%GetDescHTML2"/> 
<text label="Workspace folder:" id="txWorkDir2" size="40" title="Root workspace folder where Studio documents will be saved to." disabled="true" value=""/>
	
<!-- layout of controls for when Visual Code settings are adopted -->
	<vgroup hidden="false"  id="gWorkspace" labelPosition="left" > 
	<spacer height="10px" />
	<text label="Root export folder(s):" 
		id="txOScriptRootFolderW"
		size="20"
		name="OScriptRootFolderW"
		title="Sub-folder beneath the Workspace folder where IRIS documents will be exported to." 
	 	disabled="false" readOnly="true"
	 	/>   
	
	<spacer height="10px" />
	
	<hgroup>
	<label label="Category Sub-folder(s):"  labelClass="middleVAlign"/>
	<spacer width="25px"/>
	<dynaTree id="dtOScriptCategoriesW"  childIndent="20" showFolders="true" showLines="true"  >
	</dynaTree>
	</hgroup>
	</vgroup>

<!-- layout of controls for when custom Export settings are adopted -->
	<vgroup hidden="true" id="gCustom" labelPosition="left" align="left">
	<spacer height="10px" />   
	<text label="Root export folder(s):" 
		id="txOScriptRootFolder"
		size="20"
		name="OScriptRootFolder"
		labelClass="zenRequired"
		title="Sub-folder beneath the Workspace folder where IRIS documents will be exported to." 
	 	required="true"
	 	onchange="zenPage.updateState();"
	 	/>   
	<spacer height="10px" />  
	<hgroup>	
	<checkbox id="cbOSCategories" showLabel="true" caption="Use Sub-folders for specific export document file type(s)" value="false" 
	onchange="zen('fsCategories').setProperty('hidden',!zen('fsCategories').getProperty('hidden'))" />
	<spacer height="40px" /> 
	</hgroup>
	<fieldSet id="fsCategories" hidden="true" >	
	<group id="grpCategories"  aux="1">
	<hgroup id="exportCategory_1" name="exportCategory_1"> 
	<text  id="txtXCatFolder_1" name="XCatFolder_1" label="Sub-folder name" onchange="zenPage.onChangeSubCategoryFolder(zenThis)" value="" />  
	<label label="=" valign="bottom"/>
	<combobox id="cmbXCatExtent_1" name="XCatExtent_1" editable="true" unrestricted="true" 
	label="File type(s): (use semi-colons)" valign="bottom"  onblur="zenPage.onChangeSubCategoryExtent(zenThis)" 
	 title="Multiple extentions seperated by a semi-colon is allowed"/>
 	</hgroup> 	
	</group> 
	<vgroup align="right">	
	<spacer height="10px" />  
	<button id="btnXCatAdd" caption="Add Category" valign="bottom" enclosingClass="deleteXCategory"  onclick="zenPage.addExportCategory()" />
	</vgroup>
	</fieldSet>
	</vgroup>
<!-- -->

</vgroup>
</tab>

<tab>
<vgroup labelPosition="left" cellStyle="padding: 2px; padding-left: 5px; padding-right: 5px;">
<html id="desc3" OnDrawContent="%GetDescHTML3"/>

<text label="GIT Binaries folder:" 
	id="txGitPath"
	name="GITPath"
	size="40"
	required="true"
	labelClass="zenRequired"
	title="GIT integration settings." 
	onchange="zenPage.updateState();"
	 value='C:\Program Files\Git\bin\'/> 

<spacer height="15px" />
	
<text label="Output File:" 
	id="txGitOutput"
	name="GitOutput"
	size="40"
	required="true"
	labelClass="zenRequired"
	title="Output File (and Path) for supporting GIT Integrations." 
	onchange="zenPage.updateState();"
	 value='C:\Program Files\Git\.gitOutput.txt'/>
	 
<text label="Errors File:" 
	id="txGitErrors"
	name="GitErrors"
	size="40"
	required="true"
	labelClass="zenRequired"
	title="Errors File (and path) for supporting GIT integration." 
	onchange="zenPage.updateState();"
	 value='C:\Program Files\Git\.gitError.txt'/>
</vgroup>
</tab>


</tabGroup>

<checkbox id="cbUseVSCodeSettings" name="UseVSCodeSettings" hidden='true'  />

</pane>
}

/// This method is called when the template is complete. Any
/// output to the principal device is returned to the Studio.
Method %OnTemplateAction() As %Status
{
 
	$$$SetConfig("workdir",..%GetValueById("txWorkDir"))
	
	If ..%GetValueById("cbUseVSCodeSettings") { 
		//$$$SetConfig("objectscript.export.settings","")
		//$$$SetConfig("objectscript.export.file","vscodeFile")
		$$$SetConfig("objectscript.export.folder", ..%GetValueById("txOScriptRootFolderW")) 
	} else { 
		$$$SetConfig("objectscript.export.folder",..%GetValueById("txOScriptRootFolder"))   
	}
	
	// extract export categroy details from session
	if $d(%session.Data("objectscript.export.addCategory")) {
		set key=""
		for  {
			set key=$order(%session.Data("objectscript.export.addCategory",key),1,val) quit:key=""
			$$$SetConfigExportCategory(key,val)
		}
	}
	
	$$$SetConfig("gitpath",..%GetValueByName("GITPath"))		// path to git binaries
	$$$SetConfig("output",..%GetValueByName("GitOutput"))		// temp. file to store git output
	$$$SetConfig("error",..%GetValueByName("GitErrors"))		// temp. file to store git error 
	
	
	/// $$$SetConfig("homedir","/home/ensemble")        		// path to git home directory 
	/// $$$SetConfig("authorname","John Doe")           		// [optional] author name used in git commits
	/// $$$SetConfig("authoremail","johndoe@server.com")		// [optional] author email used in git commits
	
	
	$$$SetConfig("udl","1")            					// This is now the default export format(use UDL format instead of XML)
	$$$SetConfig("xmlextension","0")           			// Only applies if 'udl' setting = 0. File extension to add when UDL setting is 0
	
	/// $$$SetConfig("on.reloadfiles",$lb("Studio.SourceControl.Sample.Callback", "Change")) 		// [optional] classmethod to call after reloading a file
	/// $$$SetConfig("on.workdirload",$lb("Studio.SourceControl.Sample.Callback", "Change"))		// [optional] classmethod to call after a workdir load operation
	/// $$$SetConfig("on.pull",$lb("Studio.SourceControl.Sample.Callback", "Change"))	// [optional] classmethod to call after a pull operation
	 
	Quit $$$OK
}

/// Provide contents of description component on the second tab.
Method %GetDescHTML1(pSeed As %String = "") As %Status
{
	Write $$$Text("<p> The Workspace Root folder points to where all files in this solution reside. <br>")
	Write $$$Text("Most of these folders and their files will be included into the GIT repository<br/>")
	Write $$$Text("<p/>")
	Quit $$$OK
}

/// Provide contents of description component on the second tab.
Method %GetDescHTML2(pSeed As %String = "") As %Status
{
	Write $$$Text("<p> The IRIS Export folder lives within the Working Folder.<br/>")
	Write $$$Text("This form specifies the name of the export folder, and optionally, the use of sub-folders for different export document types<br/>")
	Write $$$Text("<p/>")
	Quit $$$OK
}

/// Provide contents of description component on the third tab.
Method %GetDescHTML3(pSeed As %String = "") As %Status
{
  
	Write $$$Text("<p>Please specify the folder where the GIT binary executable can be found.  This will be invoked by IRIS processes on order to <br/>")
	Write $$$Text("interact with local and remote GIT repositories.<br/>")
	Write $$$Text("<p/>")
	Write $$$Text("Specify the Output and Errors text filens (and their paths) required to support the IRIS Studio + GIT binary integration.<p/>")
	Quit $$$OK
}

/*
/// Update state of controls on the wizard form.
ClientMethod updateForm() [ Language = javascript ]
{
	var type = zen('ctrlType').getValue();
	var sup = zen('ctrlApplication');
	if ('none' == type) {
		sup.setHidden(true);
	}
	else {
		sup.setHidden(false);
	}
	zenPage.updateState();
}
*/
/// This is called when the template is first displayed;
/// This provides a chance to set focus etc.
ClientMethod onstartHandler() [ Language = javascript ]
{
	// give focus to name
	var ctrl = zen('txWorkDir');
	if (ctrl) {
		ctrl.focus();
		ctrl.select();
	}
}

ClientMethod hasMultiplePages() [ Language = javascript ]
{
	return true;
}

/// Return true if this template can go to the next page (i.e., enable
/// the Next button).<br>
ClientMethod canGoNext() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();
	
	switch(tabNo) {
		case 1:	{
			return zenPage.validateTab1(false);
		}
		case 2: {
			/* check export folders */
			return zenPage.validateTab2(false)
			
		} case 3: {
			/* check file paths validity, especially GIT Binary. */
			return zenPage.validateTab3(false) 
		}
	}

	return false;
}

/// Go to the previous page of the template (if there is one).<br>
ClientMethod previousPage() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	tabGroup.showPreviousTab();
	this.updateState();
}

/// Return true if this template can go to the previous page (i.e., enable
/// the Back button).<br>
ClientMethod canGoBack() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	return (tabGroup.getCurrTabNo() > 1);
}

/// Validation handler for form built-into template.
ClientMethod formValidationHandler() [ Language = javascript ]
{
 
	var okay1 = zenPage.validateTab1(true);
	var okay2 = zenPage.validateTab2(true);
	var okay3 = zenPage.validateTab3(true);
	return (okay1 && okay2 && okay3);
}

/// Go to the next page of the template (if there is one).<br>
ClientMethod nextPage() [ Language = javascript ]
{
	if (!this.validateTab1(true)) {
		return;
	}
	
	var tabGroup = zen('tabGroup');
	tabGroup.showNextTab();
	this.updateState();
	
	if (tabGroup.currTab==2) {
		
		zen("txWorkDir2").setValue(zen("txWorkDir").getValue())
	
		// check if VSCode settings exist, and offer option to use them   
		ans=false
		if (zenPage.HasVSCodeWorkspaceSettings(zen("txWorkDir").getValue())==true) {
			var ans=confirm("This root folder contains Visual Code settings (settings.json) that specifies ObjectScript export folder details. \n\n Do you want to use them ?")

			if (ans==true) {
				err=zenPage.GetVSCodeSettings(zen("txWorkDir").getValue(),"")
				if (err="") {
					zen("cbUseVSCodeSettings").setValue(true)
					zenPage.showExportSettings("W")
				} else {
					alert(err)
					return false
				}
				
			}
		} else {
			zenPage.showExportSettings("")
		}
	}
}

ClientMethod validateTab1(speak) [ Language = javascript ]
{
	workFolder=zen("txWorkDir").value 
	workFolder=zenPage.normaliseFolderPath(workFolder,true,"Workspace folder")
	zen("txWorkDir").setProperty("value",workFolder)

	if (workFolder=="") { 
		if (speak==true) {alert("Workspace Folder is a required field")}
		return false
	 }

	return true;
}

ClientMethod validateTab2(speak) [ Language = javascript ]
{
	
	/// if NOT adopting VSCode Workspace settings, check we have a folder for IRIS exported items.
	if (zen("cbUseVSCodeSettings").getValue()==true) {
		OScriptRootFolder=zenPage.normaliseFolderPath(zen("txOScriptRootFolderW").value,true,"Root IRIS Export folder")
		zen("txOScriptRootFolderW").setProperty("value",OScriptRootFolder)
		
		if (OScriptRootFolder=="") {
			if (speak==true) {alert("Root export folder for IRIS exported documents cannot be blank. Adjust ObjecScript settings in Visual Code App before proceeding.")}
			return false
		} 
		zenPage.GetExportCategorySettingsW()
		return true
		
	} else if (zen("cbUseVSCodeSettings").getValue()==false) {
		// we are using custom IRIS Export folder settings. Check all is in order.
		OScriptRootFolder=zenPage.normaliseFolderPath(zen("txOScriptRootFolder").value,true,"Root IRIS Export folder")
		zen("txOScriptRootFolder").setProperty("value",OScriptRootFolder)
		
		if (OScriptRootFolder=="") {
			if (speak==true) {alert("Root export folder for IRIS exported documents cannot be blank.")}
			return false
		} 
		var errMsg=zenPage.GetExportCategorySettings()
		if (errMsg!="") {
			alert(errMsg)
			return false
		}
		return true
	}
		
	return true;
}

ClientMethod validateTab3(speak) [ Language = javascript ]
{
	var GitPath=zen("txGitPath").value
	GitPath=zenPage.normaliseFolderPath(GitPath,true,"GIT Binary folder")
	zen("txGitPath").setProperty("value",GitPath) 

	
	var OutputFilePath=zen("txGitOutput").value
	zen("txGitOutput").setProperty("value",OutputFilePath) 

	var ErrorFilePath=zen("txGitErrors").value
	zen("txGitErrors").setProperty("value",ErrorFilePath) 
 
	return true
}

/// Switch UI group based on user selection:
/// if selection = 'W'  - user has chosen to adopt the vscode settings.json foundin the workspace folder
/// if selection = ''   - use hase chosen to create own, specific, export folder settings.
/// This code is called before displaying tab2.
/// 
/// Not supported: selection='U', where user (workstation) settings exist seperate from workspace folder.
ClientMethod showExportSettings(selection) [ Language = javascript ]
{
	 
 	if (selection=="W") {
	 	zenSetProp("gWorkspace","hidden",false)
	 	zenSetProp("gCustom","hidden",true)
		var ctrlFolder=zen("dtOScriptCategoriesW") 
		ctrlFolder.refreshContents() 
		
 	} else if (selection=="U") {
		// Not supported. 
		
 	} else {
	 	zenSetProp("gWorkspace","hidden",true)
	 	zenSetProp("gCustom","hidden",false)
 	}
     
	return
}

ClientMethod onChangeSubCategoryFolder(control) [ Language = javascript ]
{
 
	folderName=control.value 
	if (folderName=="") {
		alert("An Export Sub-folder name must be specified.")
		return
	}
	folderName=zenPage.normaliseFolderPath(folderName,true,"Sub-folder name")
	control.setValue(folderName)
	
	return
}

/// Validate user input of extension (format of data entered), and clean it up
ClientMethod onChangeSubCategoryExtent(control) [ Language = javascript ]
{
	folderExtent=control.value 
	if (folderExtent=="") {
		alert("An Export File type extention must be specified.")
		control.focus()
		return
	}
	
	folderExtent=folderExtent+";"   
	extents=folderExtent.split(";") 
	extCount=extents.length 
	
	clean=""
	errs=""
	
	for (var i=0; i<(extCount); i++) { 
		ext=extents[i]
		if (ext=="") { continue }
		
		ext=ext.replace(/[^a-zA-Z0-9]/g,'');
		if (ext=="*.") { continue }
		if (clean!=="") {
			clean=clean+";"
		}
		clean=clean+"*."+ext
		if (zenPage.exportTypes.indexOf(ext)==-1) {
			errs=errs+"*."+ext+","
		}
	}
	
	if (errs!=="") {
		alert("Invalid Extention types specified : \n"+errs+"\n")
		control.focus ()
		return
	}
	control.setProperty("value",clean)
	
	return
}

ClientMethod addExportCategory() [ Language = javascript ]
{
	grpCategories=zen("grpCategories") 
	idCount=grpCategories.getProperty('aux') 
	 
	for (var i=1; i<(idCount+1); i++) { 
		if (zen("exportCategory_"+i)==undefined) { continue }
		
		folderName=zen("txtXCatFolder_"+i).value
		folderName=zenPage.normaliseFolderPath(folderName,true,"Category sub-folder")
		
		zen("txtXCatFolder_"+i).setProperty("value",folderName)
		if (folderName=="") {
			alert("An empty Export Sub-folder name is not allowed.")
			return false
		}
		
		folderExtent=zen("cmbXCatExtent_"+i).value
		if (folderExtent=="") {
			alert("An empty Export File type extention is not allowed.")
			return false
		}
	} 
	
	idCount=Number(idCount)+1
	
	hgroup=zenPage.createComponent("hgroup")
	hgroup.setProperty("id","exportCategory_"+idCount)
	hgroup.setProperty("name","exportCategory_"+idCount)
	
	lbl2=zenPage.createComponent("label")
	lbl2.setProperty("label","=")
	lbl2.setProperty("valign","bottom")
	
	txtFolder=zenPage.createComponent("text")
	txtFolder.setProperty("id","txtXCatFolder_"+idCount)
	txtFolder.setProperty("name","XCatFolder_"+idCount)
	txtFolder.setProperty("onchange","zenPage.onChangeSubCategoryFolder(zenThis)")
 	
	cmbExtent=zenPage.createComponent("combobox")
	cmbExtent.setProperty("id","cmbXCatExtent_"+idCount)
	cmbExtent.setProperty("name","XCatExtent_"+idCount)
	cmbExtent.setProperty("valueList",zenPage.exportTypes)
	cmbExtent.setProperty("editable",true) 
	cmbExtent.setProperty("unrestricted",true) 
	cmbExtent.setProperty("valign","bottom")
	cmbExtent.setProperty("onchange","zenPage.onChangeSubCategoryExtent(zenThis)")
	
	btnDelete=zenPage.createComponent("button")
	btnDelete.setProperty("id","btnXCatDelete_"+idCount)
	btnDelete.setProperty("valign","bottom")
	btnDelete.setProperty("caption","Delete")
	btnDelete.setProperty("onclick","zenPage.removeXCat('"+idCount+"')")
	
	spacer=zenPage.createComponent("spacer")
	spacer.setProperty("width","5px") 
		
	hgroup.addChild(txtFolder)
	hgroup.addChild(lbl2)
	hgroup.addChild(cmbExtent)
	hgroup.addChild(spacer)
	hgroup.addChild(btnDelete)
	
	grpCategories.addChild(hgroup)
	console.log(grpCategories)
	
	grpCategories.setProperty('aux',idCount)  
	grpCategories.refreshContents()
	 
	
	return true
}

ClientMethod removeXCat(id) [ Language = javascript ]
{
	child=zen('exportCategory_'+id)
	zenPage.removeChild(child)
	 
	return
}

ClientMethod normaliseFolderPath(folderPath, speak, fieldName) [ Language = javascript ]
{
	if (folderPath=="") {
		return folderPath
	}
	
	var original=folderPath

	// check for drive letter
	driveN=folderPath.indexOf(":")
	var drive=""
	if (driveN!==-1) {
		drive=folderPath.substring(0,driveN+1)
		folderPath=folderPath.substring(driveN+1)
	} 
	
	// remove invalid type of slashes
	var regex = new RegExp('\\/', 'g');
	folderPath=folderPath.replace(regex,zenPage.folderDelimeter)
	folderPath=folderPath.replace(/[:*?><|"]/g,'');
	
	folders=folderPath.split(zenPage.folderDelimeter) 
	folderCount=folders.length 
	clean="" 
	for (var i=0; i<(folderCount); i++) { 
		folder=folders[i]
		if (folder!=="") {
			clean=clean+folder+zenPage.folderDelimeter
		}
	}
	
	if (drive!=="") {
		clean=drive+zenPage.folderDelimeter+clean
	}
	
	if ((clean!==original)&&(speak==true)) {	
		if (clean==(original+zenPage.folderDelimeter)) {
			// don't raise message just for adding delimeter to the front of the user input

		} else {
			alert("Warning: "+fieldName+" path(s) specified have been adjusted to remove invalid characters.")
		}
	}
	
	return clean
}

/// This callback is called after the server-side page 
/// object and all of its children are created.<br/>
/// Subclasses can override this to add, remove, or modify 
/// items within the page object model, or to provide values
/// for controls.
Method %OnAfterCreatePage() As %Status
{
	// identity appropriate global name to use as data global for workspace tree folder component.
	set dataGlobalW="^CacheTempGitStudio."_%session.SessionId
	k @dataGlobalW
		
	set dtWorkspace=%page.%GetComponentById("dtOScriptCategoriesW")
	set dtWorkspace.dataGlobal=dataGlobalW 
	
	set cmbExtent=%page.%GetComponentById("cmbXCatExtent_1")
	set cmbExtent.valueList=..exportTypes

	set txOScriptRootFolder=%page.%GetComponentById("txOScriptRootFolder")
	set txOScriptRootFolder.value=%page.OScriptRootFolderDefault
	
	Quit $$$OK
}

Method HasVSCodeWorkspaceSettings() As %Boolean [ ZenMethod ]
{

	return 1
}

/// GetVSCodeSettings, for logged on user and current working folder combination 
Method GetVSCodeSettings(WorkDir As %String, LoggedOnUser As %String = "") As %String [ ZenMethod ]
{
	set tSC=$$$OK
	do %page.%SetValueById("cbUseVSCodeSettings",0)
	
	set dtWorkspace=%page.%GetComponentById("dtOScriptCategoriesW") 
	set dataGlobalW=dtWorkspace.dataGlobal	
	k @dataGlobalW	
	
	set err=""
	
	Try {
		set workspaceSettings=WorkDir_".vscode"_%page.folderDelimeter_"settings.json" 
		set userSettings=""
		if LoggedOnUser'="" {
			set userSettings="c:\Users\"_LoggedOnUser_"\AppData\Roaming\Code\User\settings.json" 
		}
		
		for settings=userSettings,workspaceSettings {
			continue:settings=""
			
			if ##class(%File).Exists(settings) {				   
				
				// prepare to read settings.		
				set file=##class(%FileCharacterStream).%New()
				set file.Filename=settings 

				set json={}.%FromJSON(file)
				set objectScriptFolder=""
				if json."objectscript.export.folder"'="" {
					set objectScriptFolder=json."objectscript.export.folder"
				}
				if json."objectscript.export".folder'="" {
					set objectScriptFolder=json."objectscript.export".folder
				} 
				set objectScriptFolder=$tr(objectScriptFolder,"/\",%page.folderDelimeter)
				set:$e(objectScriptFolder,*)'=%page.folderDelimeter objectScriptFolder=objectScriptFolder_%page.folderDelimeter
								
				// check for export categories, reset if exist in USER and Workspace settings.
				if json."objectscript.export".addCategory=1 {
					kill:$d(OScriptCategoriesW) OScriptCategoriesW
					
					set categories=json."objectscript.export.addCategory"
				  	set iterator=categories.%GetIterator()
			   		while iterator.%GetNext(.key,.val) { 
			   			set OScriptCategoriesW(val,"*."_key_" files")=""
			   		}
				}
				
				// place objectscript.export.addCategory (category folder information) into dynaTree global for display
				
			}
			
			if '$D(objectScriptFolder) {
				set err="The Root Object Script folder (usually 'src\') could not be resolved from existing settings.json files found.	\nPlease fix VSCode settings.json files before completing this wizard."
			} else {
				do %page.%SetValueById("txOScriptRootFolderW",objectScriptFolder)
				 
				if $d(OScriptCategoriesW) {
					k @dataGlobalW merge @dataGlobalW=OScriptCategoriesW 
					do dtWorkspace.ReallyRefreshContents()
				}
			}
					
		}
	
	}
	Catch(ex) {
		set err="Error in Server method: "_ex.DisplayString()
	}
	
	quit err
}

Method GetExportCategorySettingsW() As %String [ ZenMethod ]
{
	set dtWorkspace=%page.%GetComponentById("dtOScriptCategoriesW") 
	set dataGlobalW=dtWorkspace.dataGlobal
	kill %session.Data("objectscript.export.addCategory")
	if $order(@dataGlobalW@(""))'="" {
		set folder=""
		for  {
			set folder=$order(@dataGlobalW@(folder)) quit:folder=""
			set type=""
			for  {
				set type=$order(@dataGlobalW@(folder,type)) quit:type=""
				set ext=$piece(type,"*.",2),ext=$piece(ext," files")
				set %session.Data("objectscript.export.addCategory",ext)=folder
			}
		}
	}
	quit ""
}

Method GetExportCategorySettings() As %String [ ZenMethod ]
{
	kill %session.Data("objectscript.export.addCategory"),duplicate
	if %page.%GetValueById("cbOSCategories") {
		// build categories from collection of grpCategories components
		set max=..%GetComponentPropertyById("grpCategories","aux")
		for i=1:1:max {
			set txFolder="txtXCatFolder_"_i
			set cbExtent="cmbXCatExtent_"_i
			set txFolder=..%GetComponentById(txFolder),cbExtent=..%GetComponentById(cbExtent)
			if txFolder'="" { 
				set folder=txFolder.value set:$e(folder)=%page.folderDelimeter folder=$e(folder,2,*)
				set extents=cbExtent.value
				for j=1:1:$l(extents,";") {
					set ext=$piece(extents,";",j),ext=$piece(ext,"*.",2)
					if $d(%session.Data("objectscript.export.addCategory",ext)),($g(%session.Data("objectscript.export.addCategory",ext))'=folder) {
						set duplicate=$piece(extents,";",j)
						kill %session.Data("objectscript.export.addCategory")
						quit
					} else {
						set %session.Data("objectscript.export.addCategory",ext)=folder 
					}
				}
			}
		}
	}
	if $d(duplicate) {
		quit "The file extension '"_duplicate_"', has been allocated in multiple export sub-folders."
	}
	
	quit ""
}

/// Provide HTML for standard template html title box.
Method %DrawTitle(pSeed As %String) As %Status
{
	#; draw html title box
	Set tName = $$$Text("Server Template","%ZEN")
	Set tTitle = ..#TEMPLATETITLE
	Set tUserName = $$$Text("User","%ZEN")
	Set tNamespace = $$$Text("Namespace","%ZEN")

	&html<<table class="stdTitle" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
		<td align="left" width="58"><img width="30" height="30" src="#(..Link("portal/icon_sysexplore.png"))#"/></td>
		<td align="left" width="90%" style="padding-left:20px;">
		<div style="font-size: 0.6em;">#(tName)#</div>
		<div>#(tTitle)#</div></td>
		<td valign="top">&nbsp;
		<table class="stdTitleInfo" border="0" cellpadding="0" cellspacing="2">
		<tr><th>#(tUserName)#:</th><th>#($UserName)#</th></tr>
		<tr><th>#(tNamespace)#:</th><th>#($namespace)#</th></tr>
		</table>
		</td>
		</tr></table>>
	Quit $$$OK
}

/*
/// Localize the name and description for this template.
ClassMethod LocalizeName(id As %String, ByRef name As %String, ByRef description As %String) As %Status [ CodeMode = objectgenerator ]
{
#define quote(%val) $zutil(144,1,%val)

	If (%class.Abstract) {
		Do %code.WriteLine(" Quit $$$OK")
		Quit $$$OK
	}

	Set DOMAIN = $G(%parameter("DOMAIN"))
	Set TEMPLATENAME = $G(%parameter("TEMPLATENAME"))
	Set DESCRIPTION = $G(%parameter("TEMPLATEDESCRIPTION"))

	If (TEMPLATENAME '= "") {
		If (DOMAIN '= "") {
			Do %code.WriteLine(" Set name = $$$Text(" _ $$$quote(TEMPLATENAME) _ ")")
		}
		Else {
			Do %code.WriteLine(" Set name = " _ $$$quote(TEMPLATENAME))
		}
	}
	If (DESCRIPTION '= "") {
		If (DOMAIN '= "") {
			Do %code.WriteLine(" Set description = $$$Text(" _ $$$quote(DESCRIPTION) _ ")")
		}
		Else {
			Do %code.WriteLine(" Set description = " _ $$$quote(DESCRIPTION))
		}
	}
	Do %code.WriteLine(" Quit $$$OK")
	Quit $$$OK
}
*/

/*
/// Return false from this method to disable this template (for example based on the server platform)
ClassMethod IsEnabled() As %Boolean
{
	Quit 1
}
*/
/// Close the template window.
ClientMethod cancelTemplate() [ Language = javascript ]
{
	// submit the template form
	var ctrlFinal = zenPage.getComponentById('templateFinal');
	zenASSERT(ctrlFinal,'Unable to find hidden control: ctrlFinal',arguments);
	ctrlFinal.setValue(0);

	var form = zenPage.getComponentById('templateForm');
	zenASSERT(form,'Unable to find form to submit',arguments);

	// turn off form validation
	form.setProperty('autoValidate',false);
	form.submit('cancel');
}

/// Finish the template: fire the template action code
ClientMethod finishTemplate() [ Language = javascript ]
{
	if (!this.onfinishHandler()) {
		return;
	}

	// submit the template form
	var ctrlFinal = zenPage.getComponentById('templateFinal');
	zenASSERT(ctrlFinal,'Unable to find hidden control: ctrlFinal',arguments);
	ctrlFinal.setValue(1);

	var form = zenPage.getComponentById('templateForm');
	zenASSERT(form,'Unable to find form to submit',arguments);

	form.submit('finish');
}

/// Update the state of the template buttons.
/// Subclasses should call this method when they need to 
/// update the state of the footer buttons.
ClientMethod updateState() [ Language = javascript ]
{
	var btnBack = zen('btnBack');
	var btnNext = zen('btnNext');
	var btnFinish = zen('btnFinish');
	var btnHelp = zen('btnHelp');

	var multi = this.hasMultiplePages();

	if (btnBack) {
		btnBack.setProperty('hidden',!multi);
		btnBack.setProperty('disabled',!this.canGoBack());
		btnBack.setProperty('controlClass',	(this.canGoBack() ? 'commandButton' :'commandButtonDisabled'));
	}
	if (btnNext) {
		btnNext.setProperty('hidden',!multi);
		btnNext.setProperty('disabled',!this.canGoNext());
		btnNext.setProperty('controlClass',	(this.canGoNext() ? 'commandButton' :'commandButtonDisabled'));
	}
	if (btnFinish) {
		btnFinish.setProperty('disabled',!this.canFinish());
		btnFinish.setProperty('controlClass', (this.canFinish() ? 'commandButton' :'commandButtonDisabled'));
	}
	if (btnHelp) {
		btnHelp.setProperty('disabled',(''==this.helpId));
		btnHelp.setProperty('controlClass',	(this.helpId != '' ? 'commandButton' :'commandButtonDisabled'));
	}
}

/// This is called when the template is finished;
ClientMethod onfinishHandler() [ Language = javascript ]
{
	return true;
}

/// Return true if this template can Finish (i.e., enable
/// the Finish button).<br>
/// This is implemented by subclasses.
ClientMethod canFinish() [ Language = javascript ]
{
	return true;
}

/// Show the help message for this template.
/// This opens a browser and goes to the DocBook application
/// using the value given by helpId.
ClientMethod showHelp() [ Language = javascript ]
{
	this.showDocumentation(this.helpId);
}

/// Open a browser window to show documentation.
ClientMethod showDocumentation(topic) [ Language = javascript ]
{
	var url = '/csp/docbook/DocBook.UI.Page.cls?KEY=' + cspEncodeUTF8(topic);
	var win = window.open(url,'docbook','status,scrollbars,resizable,location=1,toolbar=1,menubar=1');
	win.focus();
}

/*
/// Validate that the given class name is valid.<br>
/// Returns an error message if invalid.
Method IsValidClassName(pCls As %String) As %String [ ZenMethod ]
{
	If '$ZNAME(pCls,4) {
		Quit $$$Text("The class name is invalid.","%ZEN")
	}

	#; test for existence
	If ##class(%Dictionary.ClassDefinition).%ExistsId(pCls) {
		Quit $$$Text("The class name is already in use.","%ZEN")
	}
	
	Quit ""
}
*/
ClassMethod %OnSubmit(pSubmit As %ZEN.Submit) As %Status
{
	#; bypass normal submit logic
	#; so that we can serve the Studio Template response
	Set pSubmit.%SkipProcessing = 1

	#; create a page object to use later
	If (pSubmit.%Action = "finish") {
		Set %page = ..%CreatePage()
		
		#; copy submit values into the page
		Set tID = $O(pSubmit.%Data(""))
		While (tID '= "") {
			Do %page.%SetValueByName(tID,pSubmit.%Data(tID))
			Set tID = $O(pSubmit.%Data(tID))
		}
	}

	Quit $$$OK
}

/*
/// Add this named item to the current project in Studio. If you have multiple items
/// then call this method multiple times. The <var>Name</var> must contain the type of
/// the item e.g. 'User.Test.cls' is a class, and 'TEST.mac' is a MAC routine.
ClassMethod %AddToProject(Name As %String) As %Status
{
	If Name="" Quit $$$OK
	Set %session.Data("Template","AddToProject",Name)=""
	Quit $$$OK
}

/// Add this item to source control. If you have multiple items then call this method
/// multiple times. The <var>Name</var> must contain the type of the item to add e.g.
/// 'User.Test.cls'.
ClassMethod %AddToSourceControl(Name As %String) As %Status
{
	If Name="" Quit $$$OK
	Set %session.Data("Template","AddToSourceControl",Name)=""
	Quit $$$OK
}

/// If you are making a new class template then Studio needs to be told the
/// name of this class. This is done by calling this method in the final
/// page passing the name of the class.
ClassMethod %SetClassName(Name As %String) As %Status
{
	Set %session.Data("Template","CLASS")=Name
	Quit $$$OK
}
*/

/*
/// Internal method to output the start of the XML data section
ClassMethod %TemplateHeader()
{
	Write "<?xml version=""1.0""?>",!
	Write "<template><![CDATA[BODY"_..#DELIM
	Kill %session.Data("Template")
	Quit}
*/
/// Force IE to run in its newest version.
Method %OnDrawHTMLMeta() As %Status
{
	&html<<meta http-equiv="X-UA-Compatible" content="IE=edge" />>
	Quit $$$OK
}

/// Render the contents of this ZEN page.
ClassMethod OnPage() As %Status
{
	Set tFinal = $G(%request.Data("$V_$FINAL",1))

	If (tFinal="") {  // !!! check for errors
		#; normal page processing
		Quit ##super()
	}
	
	#; Template final page
	Set tSC = $$$OK
	If ((tFinal = 1) && $IsObject($G(%page))) {
		Set tSC = %page.%OnTemplateAction()
	}

	Quit tSC
}

/*
/// Make sure template runs in correct namespace.
ClassMethod OnPreHTTP() As %Boolean
{
	Set tSC = $$$OK
	Do {
		#; remember parameters passed in from Studio
		Set %response.Context("Project") = $G(%request.Data("Project",1))
		Set %response.Context("Name") = $G(%request.Data("Name",1))
		Set %response.Context("SelectedText") = $G(%request.Data("SelectedText",1))
		Set %response.Context("User") = $G(%request.Data("User",1))
		Set %response.Context("Language") = $G(%request.Data("Language",1))
		Set %response.Context("DocumentNamespace") = $G(%request.Data("DocumentNamespace",1))

		#; set up namespace
		If $G(%request.Data("Namespace",1))'="" {
			#; first page, we get Namespace from Studio URL
			Set tNamespace = %request.Data("Namespace",1)
			Set %response.Context("$NAMESPACE") = tNamespace
	
			#; cache in session also
			Set %session.Data("$NAMESPACE") = tNamespace
			Set tSC = ##class(%ZEN.Controller).%ChangeNS(tNamespace)
			If $$$ISERR(tSC) Quit
		}
		ElseIf $G(%request.Data("$NAMESPACE",1))'="" {
			#; later pages, $NAMESPACE is set, keep it in context
			Set tNamespace = %request.Data("$NAMESPACE",1)
			Set %response.Context("$NAMESPACE") = tNamespace
			Set %session.Data("$NAMESPACE") = tNamespace
			Set tSC = ##class(%ZEN.Controller).%ChangeNS(tNamespace)
			If $$$ISERR(tSC) Quit
		}
		ElseIf $G(%session.Data("$NAMESPACE"))'="" {
			Set tNamespace = %session.Data("$NAMESPACE")
			Set %response.Context("$NAMESPACE") = tNamespace
			Set %session.Data("$NAMESPACE") = tNamespace
			Set tSC = ##class(%ZEN.Controller).%ChangeNS(tNamespace)
			If $$$ISERR(tSC) Quit
		}
	} While(0)

	If $$$ISERR(tSC) Quit 0

	// dispatch to controller
	Quit ##class(%ZEN.Controller).OnPreHTTP(..%ClassName(1),+..#CLIENTCACHE,+..#AUTONS,..#RESOURCE)
}
*/
/// Make sure template generates correct format output.
ClassMethod OnHTTPHeader(ByRef OutputBody As %Boolean) As %Status
{
	If $get(%request.Data("Namespace",1))'="" {
		Set %session.Data("Namespace")=%request.Data("Namespace",1)
		If '..#GLOBALTEMPLATE {
			Set %session.RunNamespace=%request.Data("Namespace",1)
			Do $zutil(5,%session.RunNamespace)
		}
	}

	Set tFinal = $G(%request.Data("$V_$FINAL",1))
	If (tFinal'="") {
		Set %response.ContentType="text/xml"
	}
	Do %response.WriteHTTPHeader(.OutputBody)
	If (tFinal'="") {
		Do ..%TemplateHeader()
	}
	Quit $$$OK
}

/// For final page, make sure we send the correct info to the Studio.
ClassMethod OnPostHTTP()
{
	If ($D(%request.Data("$V_$FINAL",1))) {
		Write ..#DELIM
		Set name=$order(%session.Data("Template",""))
		While name'="" {
			If (name="AddToProject") || (name="AddToSourceControl") {
				Write name,..#DELIM
				Set first=1
				Set item=$order(%session.Data("Template",name,""))
				While item'="" {
					Write $select(first:"",1:",")_item
					Set item=$order(%session.Data("Template",name,item)),first=0
				}
				Write ..#DELIM
			} Else {
				Set val=$get(%session.Data("Template",name))
				If val'="" Write name,..#DELIM,val,..#DELIM
			}
			Set name=$order(%session.Data("Template",name))
		}
		Write "]]></template>",!
	}
	Quit
}

/// This client event, if present, is fired when a keydown event occurs on the page.
ClientMethod onkeydownHandler(evt) [ Language = javascript ]
{
	// prevent backpage via keyboard in templates
	return evt.altKey ? false : true;
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	this.updateState();
	this.onstartHandler();
}

/// This client event, if present, is fired when the page 
/// is first loaded or whenever it is resized.<br>
/// If this is called at load time, then <var>load</var> will
/// be true.
ClientMethod onlayoutHandler(load) [ Language = javascript ]
{
	this.adjustSize();
}

/// Adjust size and position of components on this page.
ClientMethod adjustSize() [ Language = javascript ]
{
	var header = zenPage.getComponentById('header');
	var body = zenPage.getComponentById('body');
	var footer = zenPage.getComponentById('footer');

	if (header && body && footer) {
		var divHeader = header.getEnclosingDiv();
		var divBody = body.getEnclosingDiv();
		var divFooter = footer.getEnclosingDiv();
		var winHeight = zenGetWindowHeight();
		
		var sz = winHeight - (parseInt(divHeader.offsetHeight) + parseInt(divFooter.offsetHeight));
		sz = sz < 10 ? 10 : sz;
		divBody.style.height = sz + "px";
	}
}

}

