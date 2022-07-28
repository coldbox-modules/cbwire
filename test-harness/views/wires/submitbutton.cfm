<cfoutput>
    <div>
        <form wire:submit.prevent="clickButton">
            <button type="submit" class="btn btn-primary">Click Me</button>
            <span class="ms-4">#args.message#</span>
        </form>
    </div>
</cfoutput>