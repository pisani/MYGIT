/// Updated at 03/13/2021 03:35:26
Class Studio.SourceControl.v2.Utils Extends %RegisteredObject
{

/// Current log level
Property LogLevel As %Integer [ InitialExpression = 1 ];

Parameter DEBUG = 1;

Parameter INFO = 2;

Parameter ERROR = 7;

Method Debug(pMsg As %String, pNL As %Boolean = 1)
{
	do ..Log(..#DEBUG, pMsg, pNL)
}

Method Error(pMsg As %String, pNL As %Boolean = 1)
{
	do ..Log(..#ERROR, pMsg, pNL)
}

Method Info(pMsg As %String, pNL As %Boolean = 1)
{
	do ..Log(..#INFO, pMsg, pNL)
}

Method Log(pLevel As %String, pMsg As %String, pNL As %Boolean = 1)
{
	if pLevel >= ..LogLevel {
		write:pNL !
		write pMsg
	}
	quit
}

Method InfoArray(ByRef pOutput) As %String
{
	set next=""
	for {
		set next=$order(pOutput(next))	quit:next=""
      	do ..Log(..#INFO,pOutput(next),1)
	}

	quit $$$OK
}

Method %OnNew(LogLevel = 2) As %Status [ Private, ServerOnly = 1 ]
{
	set ..LogLevel=2
	Quit $$$OK
}

}

