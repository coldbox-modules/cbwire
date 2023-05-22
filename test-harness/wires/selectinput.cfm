<cfoutput>
    <div>
        <select wire:model="hero">
            <option value=""></option>
            <option value="Batman">Batman</option>
            <option value="Superman">Superman</option>
        </select>

        <cfif args.hero eq "Batman">
            <div class="mt-4 alert alert-primary">Bruce Wayne!</div>
        <cfelseif args.hero eq "Superman">
            <div class="mt-4 alert alert-primary">Clark Kent!</div>
        <cfelse>
            <div class="mt-4 alert alert-danger">Select a hero please.</div>
        </cfif>
    </div>
</cfoutput>