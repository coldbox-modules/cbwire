<cfoutput>
    <div>
        <input wire:model.defer="foo">
        <button wire:click="save" class="btn btn-primary">Save</button>
        <div wire:dirty wire:target="foo">There's some stuff not saved yet.</div>
    </div>
</cfoutput>