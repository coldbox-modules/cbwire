<cfoutput>
    <div>
        <h1>Emit Up</h1>

        <cfif args.isChild>
            <button wire:click="$emitUp('postAdded')">Emit Up Via $emitUp On Button</button>
            <button wire:click="emitViaAction">Emit Up Via Action</button>
        <cfelse>
            <div>#args.message#</div>
            #wire( "EmitUp", { isChild: true } )#
            <hr>
        </cfif>
    </div>
</cfoutput>