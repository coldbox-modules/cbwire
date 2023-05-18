<cfoutput>
    <div>
        <h2>Child Component</h2>
        <div>Rendered at #now()#</div>
        <button wire:click="$refresh">Refresh</button>
    </div>
</cfoutput>