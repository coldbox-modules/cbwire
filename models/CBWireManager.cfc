component singleton {

	/**
	 * Injected settings.
	 */
	property name="settings" inject="coldbox:modulesettings:cbwire";

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
	 * Returns the current ColdBox RequestContext event.
	 *
	 * @return RequestContext
	 */
	function getEvent(){
		return variables.requestService.getContext();
	}

    /**
     * Primary entry point for cbwire requests.
     *
     * Currently uses /livewire URI to support Livewire JS.
     *
     * URI: /livewire/messages/:wireComponent
     */
	function handleIncomingRequest( event ) {
		var wireComponent = event.getValue( "wireComponent" );
        return getComponentInstance( wireComponent )
                    .getEngine()
                    .hydrate( event.getCollection() )
                    .getEngine()
                    .setIsInitialRendering( false )
                    .subsequentRenderIt()
                    .getEngine()
                    .setIsInitialRendering( false )
                    .getMemento();
	}
}
