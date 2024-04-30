<cfoutput>
    <div>
        <h1>Stream</h1>

        <button wire:click="startStream">Start Stream</button>

        <div wire:stream="count">
            Response will be here....
        </div>
    </div>
</cfoutput>