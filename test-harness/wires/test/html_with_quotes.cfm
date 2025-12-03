<cfoutput>
    <div>
        #content#
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "content": ""
    }

    function onMount( params ) {
        data.content = params.content;
    }
    // @endWire
</cfscript>