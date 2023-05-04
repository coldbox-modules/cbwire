component accessors="true" singleton {

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
	 * Returns the styles to be placed in our HTML head.
	 *
	 * @return String
	 */
	function getStyles(){
		return getController().getRenderer().renderView( view = "styles", module = "cbwire", args = { settings : getSettings() } );
	}

	/**
	 * Returns the JS to be placed in our HTML body.
	 *
	 * @return String
	 */
	function getScripts(){
		return getController().getRenderer().renderView( view = "scripts", module = "cbwire", args = { settings : getSettings() } );
	}

	/**
	 * Returns a reference to the LivewireJS entangle method
	 * which provides model binding between AlpineJS and CBWIRE.
	 *
	 * @prop The data property you want to bind client and server side.
	 *
	 * @returns string
	 */
	function entangle( required prop ){
		var lastComponentID = getRequestService().getContext().getPrivateValue( "cbwire_lastest_rendered_id" );
		return "window.Livewire.find( '#lastComponentID#' ).entangle( '#arguments.prop#' )";
	}

	/**
	 * Returns the full path to a component.
	 *
	 * @componentName String | Name of the cbwire component.
	 */
	function getRootComponentPath( required componentName ) {
		var appMapping = getController().getSetting( "AppMapping" );
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
		var componentPath = getRootComponentPath( arguments.componentName );
		try {
			return getWireBox().getInstance( componentPath );
		} catch ( Injector.InstanceNotFoundException e ) {
			// Check to see if an inline component exists
			var inlinePath = replaceNoCase( componentPath, ".", "/", "all" );
			inlinePath = expandPath( "/" & inlinePath & ".cfm" );
			
			if ( fileExists( inlinePath ) ) {

				var fileContents = fileRead( inlinePath );
				var inlineContents = "";
				var remainingContents = "";

				var startedWire = false;
				var endedWire = false;

				for ( var line in fileContents.listToArray( chr(10) ) ) {
					if ( line contains "// @Wire" ) {
						startedWire = true;
						continue;
					}
					if ( line contains "// @EndWire" ) {
						endedWire = true;
						continue;
					}

					if ( startedWire && !endedWire ) {
						inlineContents &= line & chr( 10 );
					} else {
						remainingContents &= line;
					}
				}

				var currentDirectory = getDirectoryFromPath( getCurrentTemplatePath() );

				var emptyInlineComponent = fileRead( currentDirectory & "EmptyInlineComponent.cfc" );

				emptyInlineComponent = replaceNoCase( emptyInlineComponent, "// Inline Contents Goes Here", inlineContents, "one" );

				var uuid = createUUID();

				fileWrite( currentDirectory & "tmp/#uuid#.cfc", emptyInlineComponent );
				fileWrite( currentDirectory & "tmp/#uuid#.cfm", remainingContents );
				var comp = getWireBox().getInstance( "cbwire.models.tmp.#uuid#" );

				comp._setInlineComponentType( arguments.componentName );
				comp._setInlineComponentId( uuid );

				return comp;

			} else {
				rethrow;
			}
		}
	}

	/**
	 * Returns the cbwire wiresLocation setting.
	 * Defaults to 'wires'
	 *
	 * @return String
	 */
	function getWiresLocation(){
		var settings = getSettings();
		if ( structKeyExists( settings, "wiresLocation" ) ) {
			return settings.wiresLocation;
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
		return getRequestService().getContext();
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
			._hydrate()
			._subsequentRenderIt()
			._getMemento();
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
