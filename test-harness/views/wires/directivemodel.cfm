<cfoutput>
    <div>
        <div>
            Message: <span class="fw-bold">#args.message#</span>
        </div>
        <div class="mt-4">
            <input wire:model="message" type="text">
        </div>
        <div class="mt-4">
            <textarea wire:model="message"></textarea>
        </div>
        <div class="mt-4">
            With one second debounce:
            <div>
                <textarea wire:model.debounce.1s="message"></textarea>
            </div>
        </div>
        <div class="mt-4">
            With lazy attribute, waits for onBlur:
            <div>
                <textarea wire:model.lazy="message"></textarea>
            </div>
        </div>

    </div>
</cfoutput>