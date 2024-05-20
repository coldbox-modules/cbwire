<cfoutput>
    <div>
        <form wire:submit.prevent="clickButton">
            <button type="submit" class="btn btn-primary">Click Me</button>
            <cfif message.len()>
                <span wire:transition.duration.3000ms class="ms-4">#message#</span>
            </cfif>
        </form>
    </div>
</cfoutput>