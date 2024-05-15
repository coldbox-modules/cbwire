<cfoutput>
    <div>
        <!--- #serializeJson( data )# --->
        <h1>Counter</h1>
        <p class="fs-2">Current: #counter#</p>
        <p class="fs-2">Is Even: #isEven#</p>
        <div class="mt-5">
            <button class="btn btn-primary" wire:click="increment">Increment</button>
            <button class="btn btn-primary" wire:click="incrementBy( 10 )">Increment By 10</button>
            <button class="btn btn-primary" wire:click="decrement">Decrement</button>
            <div>
                <a href="" wire:click.prevent="incrementBy( 10 )">Increment By 10</a>
            </div>
        </div>
        <div class="mt-5">
            <cfif isEven>
                <div wire:transition.delay.300ms.duration.1000ms class="alert alert-success">
                    The number is even!
                </div>
            </cfif>
        </div>
    </div>
</cfoutput>