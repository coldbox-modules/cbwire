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
            <!-- City -->
            <div class="mb-3">
                <label for="city" class="form-label">City</label>
                <input wire:model="city" type="text" class="form-control" id="city" name="city" placeholder="Enter city">
                <div class="text-danger" id="error-city"></div>
            </div>
            <!-- State -->
            <div class="mb-3">
                <label for="state" class="form-label">State</label>
                <input wire:model="state" type="text" class="form-control" id="state" name="state" placeholder="Enter state">
                <div class="text-danger" id="error-state"></div>
            </div>
            <!-- Zip Code -->
            <div class="mb-3">
                <label for="zipcode" class="form-label">Zip Code</label>
                <input wire:model="zipCode" type="text" class="form-control" id="zipcode" name="zipcode" placeholder="Enter zip code">
                <div class="text-danger" id="error-zipcode"></div>
            </div>
            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input wire:model="email" type="email" class="form-control" id="email" name="email" placeholder="Enter email">
                <div class="text-danger" id="error-email"></div>
            </div>
            <!-- Reset Button -->
            <button type="submit" class="btn btn-primary">Submit</button>
            <button wire:click="resetForm" type="button" class="btn btn-secondary">Reset</button>

            <cfif submitted>
                <div wire:transition class="mt-3 alert alert-success" role="alert">
                    <strong>Success!</strong> Your form has been submitted.
                </div>
            </cfif>
        </form>
    </div>
    
</div>
</cfoutput>