<cfoutput>
    <div>
        <div>
            <h1>#args.conference#</h1>
        </div>
        <div class="mt-4">
            <a href="##" wire:click.prevent="changeConference" type="button" class="btn btn-primary me-2">Change Conference</button>
            <a href="##" wire:click.prevent="addYear( '2022' )" type="button" class="btn btn-primary me-2">Add Year</button>
            <a href="##" wire:click.prevent="resetConference" class="btn btn-secondary">Reset</a>
        </div>
    </div>
</cfoutput>