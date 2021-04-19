component accessors="true" {

	property name="renderer" inject="coldbox:renderer";
	property name="wirebox" inject="wirebox";
	property name="livewireRequest" type="LivewireRequest";
	property name="initialRendering" default="true";

	function init( required LivewireRequest livewireRequest ){
		this.setLivewireRequest( livewireRequest );
	}

	function getId(){
		// match Livewire's 21 characters
		return createUUID().replace( "-", "", "all" ).left( 21 );
	}

	function getInitialPayload(){
		return {
			"fingerprint" : {
				"id"     : "#getID()#",
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
				"data"     : getData(),
				"dataMeta" : [],
				"checksum" : "2731fee42e720ea86ae36f5f076eca0943c885857c098a55592662729341e9cb"
			}
		};
	}

	function getMemento(){
		return {
			"effects" : {
				"html"  : this.render(),
				"dirty" : [
					"count" // need to fix
				]
			},
			"serverMemo" : {
				"htmlHash" : "71146cf2",
				"data"     : getData(),
				"checksum" : "1ca298d9d162c7967d2313f76ba882d9bce208822308e04920c2080497c04fc1"
			}
		}
	}

	function getData(){
		return getMetadata( this ).properties.reduce( function( agg, prop ){
			if ( structKeyExists( this, "get" & prop.name ) ) {
				agg[ prop.name ] = this[ "get" & prop.name ]( );
			}
			return agg;
		}, {} );
	}

	function hasMethod( methodName ) {
		return structKeyExists( this, methodName );
	}

	function hydrate(){
		var livewireRequest = getLivewireRequest();
		var context = livewireRequest.getCollection();

		setInitialRendering( false );

		if ( livewireRequest.hasServerMemo() ) {
			livewireRequest.getServerMemo().data.each( function( key, value ){
				this[ "set#key#" ]( value );
			} );
		}

		if ( livewireRequest.hasUpdates() ) {

			livewireRequest.getUpdates().each( function( update ){

				if ( update.isType( "callMethod" ) ) {

					if ( update.hasCallableMethod( this ) ) {
						callMethod( update );
						return;
					}

					throw(type="LivewireMethodNotFound", message="Method '" & update.getPayloadMethod() & "' not found on your component." );
				}

				if ( update.isType( "syncInput" ) ) {
					this[ "set" & update[ "payload" ][ "name" ] ]( update[ "payload" ][ "value" ] );
				}
			} );
		}

		return this;
	}

	function renderView(){
		// Pass the properties of the Livewire component as variables to the view
		arguments.args = getData();

		var rendering = renderer.renderView( argumentCollection = arguments );

		// Add livewire properties to top element to make livewire actually work
		// We will need to make this work with more than just <div>s of course
		if ( getInitialRendering() ) {
			rendering = rendering.replaceNoCase(
				"<div",
				"<div wire:id=""#getId()#"" wire:initial-data=""#serializeJSON( getInitialPayload() ).replace( """", "&quot;", "all" )#""",
				"once"
			);
		} else {
			rendering = rendering.replaceNoCase(
				"<div",
				"<div wire:id=""#getId()#""",
				"once"
			);
		}

		return rendering;
	}

	function $mount() {
		if ( structKeyExists( this, "mount" ) && isCustomFunction( this.mount ) ) {
			this[ "mount" ](
				event = livewireRequest.getEvent(),
				rc = livewireRequest.getCollection(),
				prc = livewireRequest.getCollection( private=true )
			);
		}
		return this;
	}

	function $set( propertyName, value ) {
		this[ "set#propertyName#" ]( value );
	}

	private function callMethod( required LivewireUpdate update ) {
		this[ update.getPayloadMethod() ]( argumentCollection=update.getPassedParamsAsArguments() );
	}

}
