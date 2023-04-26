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
	 * Returns the full path to a component.
	 *
	 * @componentName String | Name of the cbwire component.
	 */
	function getRootComponentPath( required componentName ) {
		var appMapping = variables.controller.getSetting( "AppMapping" );
		var wireRoot = ( len( appMapping ) ? appMapping & "." : "" ) & getWiresLocation();

		if ( reFindNoCase( "#appMapping#\.", arguments.componentName ) ) {
			return arguments.componentName;
		} else {
			return "#wireRoot#.#arguments.componentName#";
		}
	}

	/**
	 * Returns a cbwire component using the root "HelloWorld" convention.
	 *
	 * @componentName String | Name of the cbwire component.
	 *
	 * @return Component
	 */
	function getRootComponent( required componentName ){
		return variables.wirebox.getInstance( getRootComponentPath( arguments.componentName ) );
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
			//arguments.componentName = reReplaceNoCase( arguments.componentName, wiresLocation & "\.", "", "one" );
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
	function handleIncomingRequest( event, rc, prc ){
		var wireComponent = event.getValue( "wireComponent" );
		return getComponentInstance( wireComponent )
			.getEngine()
			.hydrate()
			.subsequentRenderIt()
			.getMemento();
	}

	function handleFileUpload( event, rc, prc ){
		var results = fileUploadAll( destination = expandPath( "/" ), onConflict = "makeUnique" );
		var paths = results.map( function( result ){
			var id = createUUID();
			fileWrite( expandPath( "/#id#.json" ), serializeJSON( result ) );
			return id;
		} );
		return { "paths" : paths };
	}

	function handlePreviewFile( event, rc, prc ){
		var uuid = event.getValue( "uploadUUID", "" );
		if ( !len( uuid ) ) {
			return event.noRender();
		}

		var metaJSON = deserializeJSON( fileRead( expandPath( "./#uuid#.json" ) ) );
		var contents = fileReadBinary( expandPath( "./#metaJSON.serverFile#" ) );
		event
			.sendFile(
				file = contents,
				disposition = "inline",
				extension = metaJSON.serverFileExt,
				mimeType = "#metaJSON.contentType#/#metaJSON.contentSubType#"
			)
			.noRender();
	}

}
