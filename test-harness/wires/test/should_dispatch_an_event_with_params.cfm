<cfscript>
    // @startWire
    function dispatchWithParams() {
        dispatch( "someEvent", { name: "CBWIRE" } );
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        Component
    </div>
</cfoutput>
