<cfoutput>
    <div>
        Nested component 2
        <div><button wire:click="saySomething">Say Something Again</button></div>
        <div>#args.message#</div>       
    </div>
</cfoutput>