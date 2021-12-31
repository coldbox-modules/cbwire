<cfoutput>
    <div>
        <h1>Flash Component</h1>
        <button wire:click="doSomething">Do Something</button>
        <button wire:click="doNothing">Do Nothing</button>
        <cfif flash.exists( "notice" )>
            <div>#flash.get( "notice" )#</div>
        </cfif>
    </div>
</cfoutput>