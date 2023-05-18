<cfoutput>
    <div>
        <button wire:click="click" type="button" class="btn btn-primary">Click Me</button>
        <cfif args.clicked>
            #wire( "NestedComponents" )#
        </cfif>
    </div>
</cfoutput>