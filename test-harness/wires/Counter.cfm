<cfoutput>
    <div>
        <div>
            Counter: #counter#
        </div>
        <div>
            <button wire:click="increment">Increment</button>
        </div>
    </div>
</cfoutput>

<cfscript>
    // data properties
    data = {
        "counter": 0 // default value
    };

    // actions
    function increment() {
        data.counter += 1;
    }
</cfscript>
