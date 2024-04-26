<cfoutput>
    <div>
        <div>
            Counter: #count#
        </div>
        <div>
            <button wire:click="increment">Increment</button>
        </div>

        #wire( "DataBinding", {}, "data-binding")#
    </div>
</cfoutput>
