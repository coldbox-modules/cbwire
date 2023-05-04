<cfoutput>
    <div x-data="{ 
        counter: #entangle( 'counter' )#.defer,
        name: #entangle( 'name' )#.defer
    }">
        <div>CBWIRE value: #args.counter#</div>
        <div>AlpineJS value: <span x-html="counter"></span></div>
        <button wire:click="increment" type="button">Increment with CBWIRE</button>
        <button @click="counter += 1" type="button">Increment with AlpineJS</button>

        <div class="my-5">
            <div><input type="text" x-model="name" @click.outside="$wire.$refresh()"></div>
            <span x-html="name"></span>
            <template x-if="name">
                <div x-html="name.length"></div>
            </template>
            <br>
            CBWIRE value: #args.name#
        </div>
    </div>
</cfoutput>