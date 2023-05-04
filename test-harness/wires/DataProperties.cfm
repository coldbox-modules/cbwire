<cfoutput>
    <div>
        <h1>Welcome To #args.conference#</h1>
        <div>
            toggle value: #args.toggleValue#
            <button wire:click="$toggle( 'toggleValue' )">Toggle value</button>
        </div>
    </div>
</cfoutput>