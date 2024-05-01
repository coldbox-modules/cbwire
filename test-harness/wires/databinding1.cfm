<cfoutput>
    <form>
        <div class="mb-3">
            <label for="username" class="form-label">Username</label>
            <input wire:model.live="username" type="text" class="form-control" id="username" name="username">
        </div>
        <cfif username.len()>
            <div class="alert alert-info">
                You typed in <span class="fw-bold">#username#</span>
            </div>
        <cfelse>
            <div class="alert alert-danger">
                Please enter your username.
            </div>
        </cfif>
        <!--- <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="email" class="form-control" id="email" name="email">
            <div id="emailError" class="form-text text-danger"></div>
        </div>
        <div class="mb-3">
            <label for="password" class="form-label">Password</label>
            <input type="password" class="form-control" id="password" name="password">
            <div id="passwordError" class="form-text text-danger"></div>
        </div> --->
        <!--- <button type="submit" class="btn btn-primary w-100">Sign Up</button> --->
    </form>
</cfoutput>