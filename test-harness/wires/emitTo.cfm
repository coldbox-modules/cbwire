<cfoutput>
    <div>
        <button wire:click="someAction">Fire this.$emitTo( "livewire.FireEvent2", "someEvent" ) within an action</button>
        <hr>
        <h1>FireEvent2</h1>
        #wire( "FireEvent2" )#
    </div>
</cfoutput>