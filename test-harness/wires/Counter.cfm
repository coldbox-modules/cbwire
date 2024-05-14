<cfoutput>
    <div>
        #serializeJson( data )#
        <h1>Counter</h1>
        <p class="fs-2">Current: #counter#</p>
        <p class="fs-2">Is Even: #isEven#</p>
        <div class="mt-5">
            <button wire:click="increment">Increment</button>
            <button wire:click="incrementBy( 10 )">Increment By 10</button>
            <button wire:click="startOver">Start Over</button>
            <button @click="$wire.counter = 100">Increment with Alpine</button>
        </div>

        <cfif isEven>
            <div class="alert alert-success" wire:transition.opacity.duration.1000ms>
                The counter is even!
            </div>
        </cfif>

        <div class="my-5">
            <select wire:model.live="counters" multiple>
                <cfloop from="1" to="10" index="i">
                    <option value="#i#">#i#</option>
                </cfloop>
            </select>
        </div>

        <input type="text" wire:model.blur="counter" placeholder="The counter">

        <!--- <input type="text" x-model="$wire.counter" @blur="$wire.$refresh()"> --->
        My counter: <span x-text="$wire.counter"></span>
    </div>
</cfoutput>