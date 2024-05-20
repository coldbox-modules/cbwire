<cfoutput>
    <div>
        <h1>Chat</h1>
        <div class="mt-5">
            <button
                wire:click="getJoke"
                class="btn btn-primary d-block w-100">Next Joke</button>
            <hr>
            <div class="fs-1 mt-3">
                <!---
                <div wire:loading>
                    Loading...
                </div>
                <div wire:loading.remove>
                    #data.joke#
                </div>
                --->
                <div wire:stream="joke" wire:ignore>
    
                </div>
            </div>
        </div>
    </div>
</cfoutput>