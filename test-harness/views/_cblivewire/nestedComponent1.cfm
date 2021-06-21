<cfoutput>
    <div>
        Nested component 1
        <div><button wire:click="saySomething">Say Something</button></div>
        <div>#args.message#</div>
        <hr>
        #livewire( "NestedComponent2" )#
        
    </div>
</cfoutput>