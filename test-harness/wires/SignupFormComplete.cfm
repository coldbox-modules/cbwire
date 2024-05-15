<cfoutput>
<div>
    <h1>Signup Form</h1>

    #validates( "name" )#
    <!--- #serializeJson( data )# --->
    <div class="form-container">
        <form wire:submit="submitForm">
            <!-- First Name -->
            <div class="mb-3">
                <label for="name" class="form-label">Name</label>
                <input wire:model.live.debounce.500ms="name" wire:dirty.class="border-yellow" type="text" class="form-control <cfif validates( "name" )>border-green</cfif>" id="name" name="name" placeholder="Enter first name">
                <div class="text-danger" id="error-name">#getError( "name" )#</div>
            </div>
            <!-- Zip Code -->
            <div class="mb-3">
                <label for="zip" class="form-label">Zip Code</label>
                <input wire:model.live.debounce.500ms="zip" wire:dirty.class="border-yellow" type="text" class="form-control <cfif validates( "zip" )>border-green</cfif>" id="zip" name="zip" placeholder="Enter zip code">
                <div class="text-danger" id="error-zip">#getError( "zip" )#</div>
            </div>
            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input wire:model.live.debounce.500ms="email" wire:dirty.class="border-yellow" type="text" class="form-control <cfif validates( "email" )>border-green</cfif>" id="email" name="email" placeholder="Enter email">
                <div class="text-danger" id="error-email">#getError( "email" )#</div>
            </div>

            <div wire:loading wire:target="submitForm">
                Saving....
            </div>
            <!-- Reset Button -->
            <div wire:loading.remove wire:target="submitForm">
                <button type="submit" name="submitted" class="btn btn-primary" >Submit</button>
            </div>

            <cfif submitted>
                <div class="mt-3 alert alert-success" role="alert">
                    <strong>Signup Success!</strong><br>#now()#
                </div>
            </cfif>
        </form>
    </div>
</div>
</cfoutput>