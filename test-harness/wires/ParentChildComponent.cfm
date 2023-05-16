<cfoutput>
    <div>
        <h1>Parent</h1>
        <div>Rendered at #now()#</div>
        <button wire:click="$refresh">Refresh</button>

        #wire( "ChildComponent" )#
        <hr>
        #wire( "ChildComponent" )#
    </div>
</cfoutput>