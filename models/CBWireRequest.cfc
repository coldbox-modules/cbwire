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

		if ( reFindNoCase( wiresLocation & "\.", arguments.componentName ) ) {
			arguments.componentName = reReplaceNoCase( arguments.componentName, wiresLocation & "\.", "", "one" );
		}

		if ( find( "@", arguments.componentName ) ) {
			// This is a module reference, find in our module
			var params = listToArray( arguments.componentName, "@" );
			var comp = getModuleComponent( params[ 1 ], params[ 2 ] );
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
	function renderIt( componentName, parameters = {}, key = "" ){
		return getComponentInstance( arguments.componentName )
			.mount( arguments.parameters, arguments.key )
			.renderIt();
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
		var wireRoot = ( len( appMapping ) ? appMapping & "." : "" ) & getWiresLocation();

		return variables.wirebox.getInstance( "#wireRoot#.#arguments.componentName#" );
	}

	/**
	 * Returns a cbwire component using the module convention.
	 *
	 * @componentName String | Name of the cbwire component and module.
	 *
	 * @return Component
	 */
	private function getModuleComponent( required string componentName, required string moduleName ){
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
