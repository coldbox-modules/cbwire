<cfoutput>
    <div wire:poll.5s="incrementLoop">
        <h1>Polling</h1>

        <cfloop from="1" to="#loop#" index="i">
            <div wire:key="loop_#i#" wire:transition.duration.3000ms>
                #now()#
            </div>
        </cfloop>
    </div>
</cfoutput>