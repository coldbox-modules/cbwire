<cfoutput>
    <div>
        <button wire:click="$emit( 'someEvent' )">Emit An Event</button>
        <div>#args.message#</div>
    </div>
</cfoutput>