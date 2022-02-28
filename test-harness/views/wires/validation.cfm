<cfoutput>
<div>
    <cfif args.validation.hasErrors()>
        <div>WELL DANG</div>
    </cfif>
    <input wire:model.defer="firstname" class="form-control" type="text" placeholder="First Name">
    <button wire:click="submit">Submit</button>
    <cfif args.validation.hasErrors( "firstname" )>
        <div>
            <cfloop array="#args.validation.getErrors( "firstname" )#" index="error">
                <div>#error.getMessage()#</div>
            </cfloop>
        </div>
    </cfif>
</div>
</cfoutput>