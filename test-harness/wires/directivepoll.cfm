<cfoutput>
    <div>
        <!-- wire:key is important here so Livewire does proper teardown -->
        <div wire:poll.#args.seconds#s wire:key="#createUUID()#">
            Result: <span class="fw-bold">#createUUID()#</span>
        </div>
        <select wire:model.defer="seconds">
            <option value="2">2 seconds</option>
            <option value="5">5 seconds</option>
            <option value="10">10 seconds</option>
        </select>
    </div>
</cfoutput>