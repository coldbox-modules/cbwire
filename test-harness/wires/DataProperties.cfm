<cfoutput>
    <div>
        <h1>Welcome To #conference#</h1>
        <div>
            toggle value: #toggleValue#
            <button wire:click="$toggle( 'toggleValue' )">Toggle value</button>
        </div>
    </div>
</cfoutput>