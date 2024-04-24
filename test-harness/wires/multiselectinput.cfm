<cfoutput>
    <div>
        <label>
            <select wire:model.live="heroes" multiple>
                <option value="Batman">Batman</option>
                <option value="Superman">Superman</option>
                <option value="Iron Man">Iron Man</option>
            </select>
        </label>

        <cfif arrayLen( heroes )>
            <div class="mt-4 alert alert-primary">You selected <span class="fw-bold">#arrayToList( args.heroes )#</span>.</div>
        <cfelse>
            <div class="mt-4 alert alert-danger">Select a hero please.</div>
        </cfif>
    </div>
</cfoutput>