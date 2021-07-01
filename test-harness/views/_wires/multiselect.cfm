<cfoutput>
    <div>
        <select wire:model="greeting" multiple>
            <option>Hello</option>
            <option>Adios</option>
        </select>

        <cfif isArray( args.greeting )>
            <div>
                You have selected #arrayLen( args.greeting )# options.
            </div>
        </cfif>
    </div>
</cfoutput>