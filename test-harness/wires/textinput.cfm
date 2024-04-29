<cfoutput>
    <div>
        <input wire:model.live="companyName" type="text">
        Length: #companyName.len()#
        <cfif companyName.len() gt 5>
            <div class="alert alert-danger" wire:transition.duration.1000ms>
                Company name is too long
            </div>
        </cfif>
    </div>
</cfoutput>