<cfoutput>
<div>
    <input type="text" wire:model.live="message"> Length: #len( args.message )#
    <div>#args.message#</div>
</div>
</cfoutput>