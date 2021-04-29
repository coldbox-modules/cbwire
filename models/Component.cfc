/**
 * This is the base object that all cbLivewire components extend for functionality.
 * 
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components. 
 */
component {

	/**
	 * Injected ColdBox Renderer for rendering operations.
	 */
	property name="$renderer" inject="coldbox:renderer";

	/**
	 * Injected WireBox for dependency injection.
	 */
	property name="$wirebox" inject="wirebox";

	/**
	 * Injected LivewireRequest that's incoming from the browser.
	 */
	property name="$livewireRequest" inject="LivewireRequest@cbLivewire";

	/**
	 * Our beautiful, simple constructor.
	 * 
	 * @return Component
	 */
	function init(){
		variables.$initialRendering = true;
		return this;
	}

	/**
	 * Returns a 21 character UUID to uniquely identify the component HTML during rendering.
	 * The 21 characters matches Livewire's native implementation.
	 * 
	 * @return string
	 */
	function $getId(){
		return createUUID().replace( "-", "", "all" ).left( 21 );
	}

	/**
	* This method does stuff.
	*/
	function $getInitialPayload(){
		return {
			"fingerprint" : {
				"id"     : "#this.$getID()#",
				"name"   : "#getMetadata( this ).name#",
				"locale" : "en",
				"path"   : "/",
				"method" : "GET"
			},
			"effects"    : { "listeners" : [] },
			"serverMemo" : {
				"children" : [],
				"errors"   : [],
				"htmlHash" : "ac82b577",
				"data"     : this.$getData(),
				"dataMeta" : [],
				"checksum" : "2731fee42e720ea86ae36f5f076eca0943c885857c098a55592662729341e9cb"
			}
		};
	}

	/**
	 * Returns the memento for our component which holds the current 
	 * state of our component. This is returned on subsequent XHR requests
	 * called by Livewire's JS.
	 */
	function $getMemento(){
		return {
			"effects" : {
				"html"  : this.renderIt(),
				"dirty" : [
					"count" // need to fix
				]
			},
			"serverMemo" : {
				"htmlHash" : "71146cf2",
				"data"     : this.$getData(),
				"checksum" : "1ca298d9d162c7967d2313f76ba882d9bce208822308e04920c2080497c04fc1"
			}
		}
	}

	function $getData(){
		return getMetadata( this ).properties.reduce( function( agg, prop ){
			if ( structKeyExists( this, "get" & arguments.prop.name ) ) {
				arguments.agg[ arguments.prop.name ] = this[ "get" & arguments.prop.name ]( );
			}
			return arguments.agg;
		}, {} );
	}

	/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName The method name we are checking.
	 * @return boolean
	 */
	function $hasMethod( required string methodName ) {
		return structKeyExists( this, arguments.methodName );
	}

	/**
	 * This hydrates (re-populates) our component state with
	 * values provided by the incoming LivewireRequest object.
	 * 
	 * @return Component
	 */
	function $hydrate(){
		var context = variables.$livewireRequest.getCollection();

		variables.$initialRendering = false;

		if ( variables.$livewireRequest.hasServerMemo() ) {
			variables.$livewireRequest.getServerMemo().data.each( function( key, value ){
				this.$set( arguments.key, arguments.value );
			} );
		}

		if ( variables.$livewireRequest.hasUpdates() ) {

			variables.$livewireRequest.getUpdates().each( function( update ){

				if ( arguments.update.isType( "callMethod" ) ) {

					if ( arguments.update.hasCallableMethod( this ) ) {
						variables.$callMethod( arguments.update );
						return;
					}

					throw(type="LivewireMethodNotFound", message="Method '" & arguments.update.getPayloadMethod() & "' not found on your component." );
				}

				if ( arguments.update.isType( "syncInput" ) ) {
					this[ "set" & arguments.update.getPayload()[ "name" ] ]( arguments.update.getPayload()[ "value" ] );
				}
			} );
		}

		return this;
	}

	/**
	 * Renders our component's view and returns the HTML
	 * 
	 * @return string
	 */
	function renderView(){
		// Pass the properties of the Livewire component as variables to the view
		arguments.args = this.$getData();

		var rendering = variables.$renderer.renderView( argumentCollection = arguments );

		// Add livewire properties to top element to make livewire actually work
		// We will need to make this work with more than just <div>s of course
		if ( variables.$initialRendering ) {
			rendering = rendering.replaceNoCase(
				"<div",
				"<div wire:id=""#this.$getId()#"" wire:initial-data=""#serializeJSON( this.$getInitialPayload() ).replace( """", "&quot;", "all" )#""",
				"once"
			);
		} else {
			rendering = rendering.replaceNoCase(
				"<div",
				"<div wire:id=""#this.$getId()#""",
				"once"
			);
		}

		return rendering;
	}

	/**
	 * Fires when the cbLivewire component is initially created.
	 * Looks to see if a mount() method is defined on our component and if so, invokes it.
	 * 
	 * @return this
	 */
	function $mount( parameters = {} ) {

		// Injecting the state from our passed in parameters
		// variables.$populator.populateFromStruct(
		// 	target : variables,
		// 	memento : arguments.parameters,
		// 	excludes : ""
		// );

		this.$loadParameters( arguments.parameters );

		if ( structKeyExists( this, "mount" ) && isCustomFunction( this.mount ) ) {
			this[ "mount" ](
				event = variables.$livewireRequest.getEvent(),
				rc = variables.$livewireRequest.getCollection(),
				prc = variables.$livewireRequest.getCollection( private=true )
			);
		}
		return this;
	}

	/**
	 * Loads the passed parameters into our component's variables scope
	 *
	 * @parameters The parameters that we want to load into our variables scope
	 */
	function $loadParameters( required struct parameters ) {
		arguments.parameters.each( function( key, value ) {
			variables[ arguments.key ] = arguments.value;
		} );
	}

	function $set( propertyName, value ) {
		this[ "set#arguments.propertyName#" ]( arguments.value );
	}

	private function $callMethod( required LivewireUpdate update ) {
		this[ arguments.update.getPayloadMethod() ]( argumentCollection=arguments.update.getPassedParamsAsArguments() );
	}

}
