<cfscript>
    // @startWire
    function adder( a, b ) {
        return a + b;
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <p>Result: #adder( 1, 2 )#</p>
    </div>
</cfoutput>