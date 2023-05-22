<cfoutput>
    <div>
        Counter #args.counter#
        <button wire:click="increment">Click</button>
    </div>
</cfoutput>

<cfscript>
    // @Wire
    data = {
        "counter": 0
    };

    function increment() {
        data.counter += 1;
    }
    // @EndWire
</cfscript>