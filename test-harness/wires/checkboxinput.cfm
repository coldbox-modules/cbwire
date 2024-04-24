<cfoutput>
    <div>
        <label>
            Toggle
            <input wire:model.live="isChecked" type="checkbox" value="true">
        </label>

        <cfif isChecked eq "true">
            <div class="mt-4 alert alert-primary">Checkbox is checked!</div>
        </cfif>
    </div>
</cfoutput>