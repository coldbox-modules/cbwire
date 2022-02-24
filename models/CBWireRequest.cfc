/**
 * Represents an incoming CBWire request.
 */
component accessors="true" singleton {

	/**
	 * Injected ColdBox controller which we will use to access our app and module settings
	 */
	property name="controller" inject="coldbox";

	/**
	 * Injected WireBox because DI rocks.
	 */
	property name="wirebox" inject="wirebox";

	/**
	 * Injected RequestService so that we can access the current ColdBox RequestContext.
	 */
	property name="requestService" inject="coldbox:requestService";

	/**
	 * Injected settings.
	 */
	property name="settings" inject="coldbox:modulesettings:cbwire";

	/**
	 * Returns the current ColdBox RequestContext event.
	 *
	 * @return RequestContext
	 */
	function getEvent(){
		return variables.requestService.getContext();
	}

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
		return getServerMemo().data;
	}

	/**
	 * Returns the fingerprint for the request.
	 *
	 * @return Struct
	 */
	function getFingerprint(){
		return getCollection().fingerprint;
	}

	/**
	 * Returns the serverMemo from our request context.
	 *
	 * @return struct
	 */
	function getServerMemo(){
		return getCollection().serverMemo;
	}

	/**
	 * Returns true if the server memo contains children
	 */
	function hasChildren(){
		return hasServerMemo() && isStruct( getChildren() ) && len(
			structKeyList( getCollection().severMemo.children )
		);
	}

	/**
	 * Returns children in server memo
	 */
	function getChildren(){
		return getCollection().serverMemo.children;
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
		return getEvent().getCollection( argumentCollection = arguments );
	}

	/**
	 * Returns our event's private request collection.
	 *
	 * @return Struct
	 */
	function getPrivateCollection(){
		return getEvent().getPrivateCollection( argumentCollection = arguments );
	}

	/**
	 * Finds and returns our cbwire component by name, either using
	 * module syntax Component@Module or root sytax, which looks
	 * in the root "wires" folder by default.
	 *
	 * The folder can be overridden with the 'componentLocation' setting.
	 *
	 * @componentName String | The name of the component.
	 */
	function getComponentInstance( componentName ){
		// Determine our component location from the cbwire settings.
		var wiresLocation = getWiresLocation();

		if (
			reFindNoCase(
				wiresLocation & "\.",
				arguments.componentName
			)
		) {
			arguments.componentName = reReplaceNoCase(
				arguments.componentName,
				wiresLocation & "\.",
				"",
				"one"
			);
		}

		if ( find( "@", arguments.componentName ) ) {
			// This is a module reference, find in our module
			var params = listToArray( arguments.componentName, "@" );
			var comp   = getModuleComponent( params[ 1 ], params[ 2 ] );
		} else {
			// Look in our root folder for our cbwire component
			var comp = getRootComponent( arguments.componentName );
		}

		return comp;
	}

	/**
	 * Instantiates our cbwire component, mounts it,
	 * and then calls it's internal renderIt() method.
	 *
	 * @componentName String | The name of the component in your cbwire folder.
	 * @parameters Struct | The parameters you want mounted initially.
	 *
	 * @return Component
	 */
	function renderIt(
		componentName,
		parameters = {},
		key        = ""
	){
		return getComponentInstance( arguments.componentName ).$mount( arguments.parameters, arguments.key ).renderIt();
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
		arguments.comp.invokeMethod( "preUpdate" );

		// Update the state of our component with each of our updates
		getUpdates().each( function( update ){
			arguments.update.apply( comp );
		} );

		// Fire our postUpdate lifecycle event.
		arguments.comp.invokeMethod( "preUpdate" );
	}

	/**
	 * Primary handler for incoming cbwire request.
	 *
	 * @context Struct
	 */
	function handle( required component ){
		return arguments.component.$hydrate( this ).$getMemento();
	}

	/**
	 * Returns the cbwire wiresLocation setting.
	 * Defaults to 'wires'
	 *
	 * @return String
	 */
	function getWiresLocation(){
		if ( structKeyExists( variables.settings, "wiresLocation" ) ) {
			return variables.settings.wiresLocation;
		}
		return "wires";
	}

	/**
	 * Returns a cbwire component using the root "HelloWorld" convention.
	 *
	 * @componentName String | Name of the cbwire component.
	 *
	 * @return Component
	 */
	private function getRootComponent( required componentName ){
		var appMapping = variables.controller.getSetting( "AppMapping" );
		var wireRoot   = ( len( appMapping ) ? appMapping & "." : "" ) & getWiresLocation();

		return variables.wirebox.getInstance( "#wireRoot#.#arguments.componentName#" );
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
		var wireModuleRoot = modulesConfig[ moduleName ].invocationPath & "." & getWiresLocation();

		return variables.wirebox.getInstance( "#wireModuleRoot#.#arguments.componentName#" );
	}

}
