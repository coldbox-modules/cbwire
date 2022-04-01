<cfoutput>
<div>
    <form wire:submit.prevent="save">
        <input type="file" wire:model="photo">
        <button type="submit">Save Photo</button>
    </form>
</div>
</cfoutput>