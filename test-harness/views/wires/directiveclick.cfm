<cfoutput>
    <div>
        Clicks: <span class="fw-bold">#args.clicks#</span>
        <div class="mt-4">
            <button wire:click="increment" type="button">Click</button>
            <a wire:click.prevent="increment" href="">Click</a>
            <span wire:click="increment">Click</span>
        </div>
    </div>
</cfoutput>