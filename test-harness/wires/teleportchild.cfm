<cfoutput>
    <div>
        <button wire:click="runTeleport">
            Run Teleport
        </button>

        <cfif ran>
            @teleport("##teleport-div")
                <div>#now()#</div>
            @endTeleport
        </cfif>
    </div>
</cfoutput>