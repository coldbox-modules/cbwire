<cfoutput>
<div>
    <input wire:model="email" type="text" placeholder="Enter your email">
    <button wire:click="addEmail">Add Email</button>

    <cfif args.success>
        <div>Success!</div>
    </cfif>

    <cfif args.validation.hasErrors( "email" )>
        <cfloop array="#args.validation.getAllErrors( "email" )#" index="error">
            <div>#error#</div>
        </cfloop>
    </cfif>
</div>
</cfoutput>