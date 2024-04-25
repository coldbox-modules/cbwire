<cfoutput>
<div>
    <input wire:model.live="email" type="text" placeholder="Enter your email">
    <button wire:click="addEmail">Add Email</button>

    <cfif success>
        <div>Success!</div>
    <cfelse>
        <div>no success</div>
    </cfif>

    <cfif validation.hasErrors( "email" )>
        <cfloop array="#validation.getAllErrors( "email" )#" index="error">
            <div class="alert alert-danger mt-2" wire:key="#hash( error )#">
                #error#
            </div>
        </cfloop>
    </cfif>
</div>
</cfoutput>