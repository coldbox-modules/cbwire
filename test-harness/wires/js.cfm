<cfoutput>
    <div>
        Submitted: #submitted#<br>
        <span x-text="$wire.submitted"></span>
        <button class="btn btn-primary" wire:click="submit">Submit</button>
    </div>
</cfoutput>