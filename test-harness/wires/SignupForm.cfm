<cfoutput>
<div>
    <h1>Signup Form</h1>

    <div class="form-container">
        <form wire:submit="submitForm">
            <!-- First Name -->
            <div class="mb-3">
                <label for="name" class="form-label">Name</label>
                <input wire:model="name" type="text" class="form-control" id="name" name="name" placeholder="Enter first name">
                <div class="text-danger" id="error-name"></div>
            </div>
            <!-- Zip Code -->
            <div class="mb-3">
                <label for="zip" class="form-label">Zip Code</label>
                <input wire:model="zip" type="text" class="form-control" id="zip" name="zip" placeholder="Enter zip code">
                <div class="text-danger" id="error-zip"></div>
            </div>
            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input wire:model="email" type="text" class="form-control" id="email" name="email" placeholder="Enter email">
                <div class="text-danger" id="error-email"></div>
            </div>
            <!-- Reset Button -->
            <button type="submit" name="submitted" class="btn btn-primary">Submit</button>

            <cfif submitted>
                <div class="mt-3 alert alert-success" role="alert">
                    <strong>Signup Success!</strong><br>#now()#
                </div>
            </cfif>
        </form>
    </div>
</div>
</cfoutput>