<cfoutput>
    <div x-data="{ counter: #entangle( 'counter' )# }">
        <div>CBWIRE value: #args.counter#</div>
        <div>AlpineJS value: <span x-html="counter"></span></div>
        <button wire:click="increment" type="button">Increment with CBWIRE</button>
        <button @click="counter += 1" type="button">Increment with AlpineJS</button>
    </div>
</cfoutput>