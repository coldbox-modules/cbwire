<cfscript>
    // @startWire
    data = {
        "name": ""
    };

    constraints = {
        "name": { required: true, requiredMessage: "The 'name' field is required" }
    };
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <p>Has errors: #hasErrors() ? "true" : "false"#</p>
        <p>Has error: #hasError( "name" ) ? "true" : "false"#</p>
        <p>Get errors length: #getErrors().len()#</p>
        <p>Error: #getError( "name" )#</p>
    </div>
</cfoutput>