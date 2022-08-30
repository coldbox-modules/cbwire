<cfoutput>
<div>    
    <div class="my-4">
        #args.name#
    </div>
    <div>
        <button class="btn btn-primary pr-4" wire:click="changeName">Change Name</button>
        <button class="btn btn-primary" wire:click="resetName">Reset Name</button>
    </div>
</div>
</cfoutput>