<cfoutput>
    <div>
        <h1>Dot Notation Data Properties</h1>

		<cfif showSuccess >
			<div class="alert alert-success" role="alert">
				<h3>Form submitted successfully!</h3>
				<strong>Data Submitted:</strong><br>
				user.name.first: #user.name.first#<br>
				user.name.last: #user.name.last#<br>
				user.email: #user.email#<br>
				user.address.street: #user.address.street#<br>
				user.address.city: #user.address.city#<br>
				user.address.state: #user.address.state#<br>
				user.address.zip: #user.address.zip#<br>
				user.roles: #ArrayToList(user.roles)#<br>
				user.subscriptions.newsletter: #user.subscriptions.newsletter#<br>
				user.subscriptions.alerts: #user.subscriptions.alerts#<br>
			</div>
		</cfif>

		<form class="row g-3" wire:submit.prevent="submit" style="margin-bottom: 20px;" >

			<h3 class="border-bottom">User Info</h3>

			<div class="col-md-6">
				<label class="form-label">First Name</label>
				<input type="text" class="form-control" wire:model.debounce.500ms="user.name.first">
			</div>

			<div class="col-md-6">
				<label class="form-label">Last Name</label>
				<input type="text" class="form-control" wire:model.debounce.500ms="user.name.last">
			</div>


			<div class="col-md-6">
				<label class="form-label">Email</label>
				<input type="email" class="form-control"  wire:model.debounce.500ms="user.email">
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

			<h3 class="border-bottom">User Subscriptions</h3>

			<div class="col-md-12">

				<div class="form-check form-check-inline">
					<input class="form-check-input" type="checkbox" id="inlineCheckbox20" wire:model="user.subscriptions.newsletter">
					<label class="form-check-label" for="inlineCheckbox20">Newsletters</label>
				</div>

				<div class="form-check form-check-inline">
					<input class="form-check-input" type="checkbox" id="inlineCheckbox21" wire:model="user.subscriptions.alerts">
					<label class="form-check-label" for="inlineCheckbox21">Alerts</label>
				</div>

			</div>

			<div class="col-12">
				<button type="submit" class="btn btn-primary">Save</button>
			</div>

			<h3 class="border-bottom" style="margin-top: 30px;">Test Wire Client Functions</h3>

			<div class="col-12" id="wireWatchOutput" style="max-height: 100px; overflow: auto; font-size: 12px; border: 1px solid ##ccc; padding: 5px; margin-bottom: 10px;">
				<div><strong>$watch output when changing 'user.name.first'</strong></div>
			</div>

			<div class="col-6">
				<div class="d-grid gap-2">
					<button type="button" class="btn btn-primary" wire:click="setDataToNonDefaultValues()">Set Non Default Values</button>
					<button type="button" class="btn btn-primary" wire:click="resetDataAll()">resetDataAll()</button>
					<button type="button" class="btn btn-primary" wire:click="resetDataKey( 'user.name.first' )">resetDataKey( 'user.name.first' )</button>
					<button type="button" class="btn btn-primary" wire:click="resetDataKey( 'user.name.first,user.name.last' )">resetDataKey( 'user.name.first,user.name.last' )</button>
					<button type="button" class="btn btn-primary" wire:click="resetDataKey( ['user.name.first'] )">resetDataKey( ['user.name.first'] )</button>
					<button type="button" class="btn btn-primary" wire:click="resetDataKey( ['user.name.first','user.name.last'] )">resetDataKey( ['user.name.first','user.name.last'] )</button>
					<!--- rest except testing --->
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( 'user.name.first' )">resetExceptDataKey( 'user.name.first' )</button>
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( ['user.name.last'] )">resetExceptDataKey( ['user.name.last'] )</button>
					<!--- rest reset array --->
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( 'user.name.first' )">resetExceptDataKey( 'user.roles' )</button>
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( ['user.name.last'] )">resetExceptDataKey( ['user.roles'] )</button>
					<!--- rest reset booleans --->
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( 'user.subscriptions.newsletter' )">resetExceptDataKey( 'user.subscriptions.newsletter' )</button>
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( ['user.subscriptions.alerts'] )">resetExceptDataKey( ['user.subscriptions.alerts'] )</button>
					<!--- rest reset multiple keys --->
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( 'user.name.first,user.name.last' )">resetExceptDataKey( 'user.name.first,user.name.last' )</button>
					<button type="button" class="btn btn-primary" wire:click="resetExceptDataKey( ['user.name.first','user.name.last'] )">resetExceptDataKey( ['user.name.first','user.name.last'] )</button>
				</div>
			</div>

			<div class="col-6">
				<div class="d-grid gap-2">
					<button type="button" class="btn btn-primary" wire:click="$refresh">$refresh</button>
					<button type="button" class="btn btn-primary" onclick="testGet( 'user.email' )">$get( 'user.email' )</button>
					<button type="button" class="btn btn-primary" onclick="testSet( 'user.email', 'me@my.tld' )">$set( 'user.email', 'me@my.tld' )</button>
					<button type="button" class="btn btn-primary" onclick="testToggle( 'user.subscriptions.alerts' )">$Toggle : user.subscriptions.alerts</button>
					<button type="button" class="btn btn-primary" onclick="testToggle( 'user.subscriptions.newsletter' )">$Toggle : user.subscriptions.newsletter</button>
				</div>
			</div>

		</form>
		<script>
			document.addEventListener('livewire:init', () => {
				Livewire.hook('component.init', ({ component, cleanup }) => {
					if( component.id === '#_getID()#' ){
						window.__NestedDataKeys = component.$wire;
						// test $watch with nested data key
						window.__NestedDataKeys.$watch('user.name.first', ( value, old ) => {
							const container = document.getElementById( 'wireWatchOutput' );
							const newElement = document.createElement('div');
							newElement.innerHTML = "user.name.first changed => New Value: " + value + ", Old Value: " + old;
							container.appendChild( newElement );
							container.scrollTop = container.scrollHeight;
						})
					}
				});
			});
			// test clientside wire functions with nested data keys helper functions
			function testSet( key, value ){
				window.__NestedDataKeys.$set( key, value );
			}
			function testGet( key ){
				const keyValue = window.__NestedDataKeys.$get( 'user.email' );
				alert( 'user.email : ' + keyValue );
			}
			function testToggle( key ){
				window.__NestedDataKeys.$toggle( key );
			}
		</script>
    </div>
</cfoutput>