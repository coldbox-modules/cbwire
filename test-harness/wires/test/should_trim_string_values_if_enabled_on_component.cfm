<cfoutput>
    <div>
        <p>Name: #name#</p>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    trimStringValues = true;

    data = {
        "name": "Jane Doe"
    };
    // @endWire
</cfscript>