<cfoutput>
    <div>
        <label>
            Is it Shark Week?
            <input name="isSharkWeek" wire:model="isSharkWeek" type="radio" value="true"> Yes
            <input name="isSharkWeek" wire:model="isSharkWeek" type="radio" value="false" checked> No
        </label>

        <cfif args.isSharkWeek>
            <div class="mt-4 alert alert-danger">Beware of sharks!</div>
        <cfelse>
            <div class="mt-4 alert alert-primary">These waters are safe my friend.</div>
        </cfif>

    </div>
</cfoutput>