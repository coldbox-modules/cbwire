<cfoutput>
    <div>
        <form wire:submit="submit">
            <input wire:model="username" type="text" class="form-control" placeholder="Enter your name">
            <div class="mt-3">
                Alpine: <span x-text="$wire.username"></span>
            </div>
            <button class="mt-3 btn btn-primary d-block w-100" type="submit">Submit</button>
        </form>

        <cfif username.len()>
            <div class="mt-3 fs-1">
                Hello, #username#!
            </div>
        </cfif>
    </div>
</cfoutput>