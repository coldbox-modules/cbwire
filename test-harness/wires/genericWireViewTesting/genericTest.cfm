<cfscript>
    //@startWire

    data = {
        "title": "Generic Wire View Test Component",
		"testArgument": "No Test Argument Passed"
    }

    function onMount( event, rc, prc, params ){
        if( structKeyExists( params, "testArgument" ) ){
			data.testArgument = params.testArgument;
		}
    }
    //@endWire
</cfscript>

<cfoutput>
    <div>
        Title: #title#<br>
		Test Argument: #testArgument#
    </div>
</cfoutput>