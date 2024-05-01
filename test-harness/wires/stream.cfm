<cfoutput>
    <div>
        <h1>Stream</h1>

        <button class="btn btn-primary" wire:click="start">Start Processing</button>

        <cfif finished>
            <div wire:key="finish" wire:transition.opacity.duration.3000ms>
                Finished!
            </div>
        <cfelse>
            <div wire:key="response" wire:stream="response"></div>
        </cfif>
    </div>
</cfoutput>