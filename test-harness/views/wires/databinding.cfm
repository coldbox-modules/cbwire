<cfoutput>
<div>
    <input type="text" wire:model="message"> Length: #len( args.message )#
    <div>#args.message#</div>
</div>
</cfoutput>