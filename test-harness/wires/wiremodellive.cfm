<cfoutput>
    <div>
        <form wire:submit="submit">
            <input wire:model.live="username" type="text" class="form-control" placeholder="Enter your name">
        </form>

        <cfif username.len()>
            <div class="mt-3">
                Hello, #username#!
            </div>
        </cfif>
    </div>
</cfoutput>