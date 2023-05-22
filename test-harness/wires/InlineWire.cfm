<cfscript>
    // @Wire
    data = {
        "counter": 0
    };

    computed = {
        "isEven": function() {
            return data.counter % 2 == 0 ? true : false;
        }
    }

    function increment() {
        data.counter += 1;
    }
    // @EndWire
</cfscript>

<cfoutput>
    <div>
        InlineWire
        <div>
            Counter: #args.counter#
        </div>
        <div>
            Is even: #args.computed.isEven()#
        </div>
        <div>
            <button wire:click="increment">Increment</button>
        </div>
    </div>
</cfoutput>

