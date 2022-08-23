<cfoutput>
    <div>
        <h2>Data Properties</h2>
        Conference: #args.conference# 
        <div class="mt-4">
            <a href="##" wire:click.prevent="addYear" class="btn btn-primary">Add Year</a>
            <a href="##" wire:click.prevent="resetForm" class="btn btn-secondary">Reset</a>
        </div>
    </div>
</cfoutput>