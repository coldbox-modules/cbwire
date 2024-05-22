<cfscript>
    // @startWire
    function generateUUID() computed {
        return createUUID();
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <p>UUID: #generateUUID()#</p>
    </div>
</cfoutput>