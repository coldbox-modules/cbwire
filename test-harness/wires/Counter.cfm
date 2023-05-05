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

