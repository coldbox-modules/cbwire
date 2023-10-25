<cfscript>
    data = {
        "preDefinedString" : "Pre Defined String Value",
        "preDefinedNumber" : 1234
    };
</cfscript>

<cfoutput>
    <div>
        <h1>Test Wire Component Without OnMount() Event</h1>

        <h5>Output from variables.data</h5>
        <cfloop item="key" collection=#variables.data# >
             variables.data.#key# = #serializeJSON( variables.data[key] )#<br/>
        </cfloop>
        <hr>

        <h5>Output from variables</h5>
        <cfloop item="key" collection=#variables.data# >
             variables.#key# = #serializeJSON( variables[key] )#<br/>
        </cfloop>
        <hr>
        
        COMPLETED-PROCESSING
    </div>
</cfoutput>