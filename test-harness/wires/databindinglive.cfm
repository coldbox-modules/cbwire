<cfoutput>
    <div>
        <form>
        <h4>wire:model.blur</h4>
        <input wire:model.blur="username" type="text" class="form-control" placeholder="Enter your name">
        <h4>wire:model.live</h4>
        <div class="mb-3">
            <label for="username" class="form-label">Username</label>
            <input wire:model.live="username" type="text" class="form-control" placeholder="Enter your name">
        </div>
        <div>Hello <cfif username.len()>#username#<cfelse>stranger</cfif></div>
        </form>
    </div>
</cfoutput>