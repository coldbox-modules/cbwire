<cfscript>
    // @startWire
    lazy = true;

    data = {
    };

    function placeholder() {
        return "<div>Loading...</div>";
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <h1>Should isolate when using lazy=true</h1>
    </div>
</cfoutput>