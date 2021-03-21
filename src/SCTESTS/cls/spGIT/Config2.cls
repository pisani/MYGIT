/// Created using the page template: Default
Class spGIT.Config2 Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION;

/// Displayed name of this page.
Parameter PAGENAME = "abc";

/// Domain used for localization.
Parameter DOMAIN;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="">
</page>
}

}

