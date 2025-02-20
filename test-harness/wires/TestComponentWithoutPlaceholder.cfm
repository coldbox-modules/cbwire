<cfoutput>
    <div>test component without placeholder</div>
</cfoutput>

<cfscript>
    // @startWire
    data = {};

    function placeholder() {
        return "";
    }
    // @endWire
</cfscript>