<cfscript>
    // @startWire
        data = {
            "hasBooted": false
        };

        function onBoot() {
            data.hasBooted = true;
        }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <cfif hasBooted>
            <p>OnBoot Fired</p>
        </cfif>
    </div>
</cfoutput>