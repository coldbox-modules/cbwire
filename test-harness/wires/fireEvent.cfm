<cfoutput>
    <div>
        <button wire:click="someAction">Emit An Event</button>
        <button wire:click="$emit('someOtherEvent')">JS $emit('someOtherEvent')</button>
        <div>#args.message#</div>
    </div>
</cfoutput>