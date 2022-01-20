/**
 * Represents an incoming CBWire request.
 */
component accessors="true" singleton {

	/**
	 * Injected WireBox because DI rocks.
	 */
	property name="wirebox" inject="wirebox";

	/**
	 * Injected CBWireManager
	 */
	property name="cbwireManager" inject="CBWireManager@cbwire";


	/**
	 * Returns true if our request context contains a 'fingerprint' property.
	 *
	 * @return Boolean
	 */
	function hasFingerprint(){
		return structKeyExists( getCollection(), "fingerprint" );
	}

	/**
	 * Returns true if our request context contains a 'serverMemo' property.
	 *
	 * @return Boolean
	 */
	function hasServerMemo(){
		return structKeyExists( getCollection(), "serverMemo" );
	}

	/**
	 * Returns true if our server memo contains a data property.
	 *
	 * @return Boolean
	 */
	function hasData(){
		return hasServerMemo() && structKeyExists( getServerMemo(), "data" );
	}

	/**
	 * Returns our data
	 *
	 * @return Struct
	 */
	function getData(){
		return getServerMemo()[ "data" ];
	}

	/**
	 * Returns the fingerprint for the request.
	 *
	 * @return Struct
	 */
	function getFingerprint(){
		return getCollection()[ "fingerprint" ];
	}

	/**
	 * Returns the serverMemo from our request context.
	 *
	 * @return struct
	 */
	function getServerMemo(){
		return getCollection()[ "serverMemo" ];
	}

	/**
	 * Returns true if our request context contains an 'updates' property.
	 *
	 * @return Boolean
	 */
	function hasUpdates(){
		var collection = getCollection();
		return structKeyExists( collection, "updates" ) && isArray( collection.updates ) && arrayLen(
			collection.updates
		);
	}

	/**
	 * Returns an array of WireUpdate objects with our updates from the request context.
	 *
	 * @return Array | WireUpdate
	 */
	function getUpdates(){
		return getCollection()[ "updates" ].map( function( update ){
			var casedType = arguments.update.type;

			casedType = reReplaceNoCase( casedType, "^(.)", "\U\1", "one" );

			return variables.wirebox.getInstance(
				name          = "#casedType#@cbwire",
				initArguments = { "update" : arguments.update }
			);
		} );
	}

	/**
	 * Returns our event's public request collection.
	 *
	 * @return Struct
	 */
	function getCollection(){
		return cbwireManager.getEvent()
			.getCollection( argumentCollection = arguments );
	}

	/**
	 * Returns our event's private request collection.
	 *
	 * @return Struct
	 */
	function getPrivateCollection(){
		return cbwireManager.getEvent()
			.getPrivateCollection( argumentCollection = arguments );
	}

	/**
	 * Applies any updates in our request to the specified cbwire component
	 *
	 * @comp cbwire.models.Component
	 *
	 * @return Void
	 */
	function applyUpdates( comp ){
		// Fire our preUpdate lifecycle event.
		arguments.comp.$invokeMethod( "preUpdate" );

		// Update the state of our component with each of our updates
		getUpdates().each( function( update ){
			arguments.update.apply( comp );
		} );

		// Fire our postUpdate lifecycle event.
		arguments.comp.$invokeMethod( "preUpdate" );
	}

	/**
	 * Primary handler for incoming cbwire request.
	 *
	 * @context Struct
	 */
	function handle( cbwireComponent ){
		return cbwireComponent
			.$hydrate( this )
			.$getMemento( getData() );
	}

	/**
	 * Returns a cbwire component using the module convention.
	 *
	 * @componentName String | Name of the cbwire component and module.
	 *
	 * @return Component
	 */
	private function getModuleComponent(
		required string componentName,
		required string moduleName
	){
		// Verify the module
		var modulesConfig = variables.controller.getSetting( "modules" );
		if ( !modulesConfig.keyExists( moduleName ) ) {
			throw( message = "Could not find #moduleName# module to render wire #componentName#" );
		}
		// Instantion Prefix of the module
		var wireModuleRoot = modulesConfig[ moduleName ].invocationPath & "." & cbwireManager.getWiresLocation();

		return variables.wirebox.getInstance( "#wireModuleRoot#.#arguments.componentName#" );
	}

}
