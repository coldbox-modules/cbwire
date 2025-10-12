<cfoutput>
    <div>
        <h1>Dot Notation Data Properties</h1>

		<cfif showSuccess >
			<div class="alert alert-success" role="alert">
				<h3>Form submitted successfully!</h3>
				<strong>Data Submitted:</strong><br>
				First Name: #user.name.first#<br>
				Last Name: #user.name.last#<br>
				Email: #user.email#<br>
				Address: #user.address.street#<br>
				City: #user.address.city#<br>
				State: #user.address.state#<br>
				Zip: #user.address.zip#<br>
				Roles: #ArrayToList(user.roles)#<br>
			</div>
		</cfif>

		<form class="row g-3" wire:submit.prevent="submit" >

			<h3 class="border-bottom">User Info</h3>

			<div class="col-md-6">
				<label class="form-label">First Name</label>
				<input type="text" class="form-control" wire:model="user.name.first">
			</div>

			<div class="col-md-6">
				<label class="form-label">Last Name</label>
				<input type="text" class="form-control" wire:model="user.name.last">
			</div>


			<div class="col-md-6">
				<label class="form-label">Email</label>
				<input type="email" class="form-control"  wire:model="user.email">
			</div>

			<div class="col-12">
				<label class="form-label">Address</label>
				<input type="text" class="form-control" wire:model="user.address.street">
			</div>

			<div class="col-md-6">
				<label class="form-label">City</label>
				<input type="text" class="form-control" wire:model="user.address.city">
			</div>

			<div class="col-md-4">
				<label class="form-label">State</label>
				<input type="text" class="form-control" wire:model="user.address.state">
			</div>

			<div class="col-md-2">
				<label class="form-label">Zip</label>
				<input type="text" class="form-control" wire:model="user.address.zip">
			</div>

			<h3 class="border-bottom">User Roles</h3>

			<div class="col-md-12">

				<div class="form-check form-check-inline">
					<input class="form-check-input" type="checkbox" id="inlineCheckbox1" value="admin" wire:model="user.roles">
					<label class="form-check-label" for="inlineCheckbox1">Admin</label>
				</div>

				<div class="form-check form-check-inline">
					<input class="form-check-input" type="checkbox" id="inlineCheckbox2" value="editor" wire:model="user.roles">
					<label class="form-check-label" for="inlineCheckbox2">Editor</label>
				</div>

				<div class="form-check form-check-inline">
					<input class="form-check-input" type="checkbox" id="inlineCheckbox3" value="auditor" wire:model="user.roles">
					<label class="form-check-label" for="inlineCheckbox3">Auditor</label>
				</div>

			</div>

			<div class="col-12">
				<button type="submit" class="btn btn-primary">Save</button>
			</div>

		</form>
    </div>
</cfoutput>