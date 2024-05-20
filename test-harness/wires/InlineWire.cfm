<cfscript>
    // @startWire
        data = {
            "counter": 0
        };

        function isEven() computed {
            return data.counter % 2 == 0 ? true : false;
        }

        function increment() {
            data.counter += 1;
        }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        InlineWire
        <div>
            Counter: #counter#
        </div>
        <div>
            Is even: #isEven()#
        </div>
        <div>
            <button wire:click="increment">Increment</button>
        </div>
    </div>
</cfoutput>

