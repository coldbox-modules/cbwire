<cfoutput>
    <div>
        <!-- Only show when we are loading ( there is a background AJAX request running) -->
        <div wire:loading>
            <button wire:click="start" class="btn btn-primary" disabled>Start five-second process</button>
            <span>Processing...</span>
        </div>
        <!-- Show when we are not loading -->
        <div wire:loading.remove>
            <button wire:click="start" class="btn btn-primary">Start five-second process</button>
        </div>
    </div>
</cfoutput>