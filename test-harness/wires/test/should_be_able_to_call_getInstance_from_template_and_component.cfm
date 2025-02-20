<cfscript>
    // @startWire
    data = {
        "result": 0
    };

    function onMount() {
        data.result = getInstance( "Adder" ).add( 1, 2 );
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <p>OnMount Result: #result#</p>
        <p>Inline Result: #getInstance( "Adder" ).add( 1, 4 )#</p>
    </div>
</cfoutput>