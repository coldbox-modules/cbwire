component accessors="true" {

	/**
	 * Injected settings.
	 */
	property name="settings" inject="coldbox:modulesettings:cbwire";

	/**
	 * Module service
	 */
	property name="moduleService" inject="coldbox:moduleService";

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
	 * Inject SingleFileComponentBuilder
	 */
	property name="singleFileComponentBuilder" inject="SingleFileComponentBuilder@cbwire";

	/**
	 * Returns the styles to be placed in our HTML head.
	 *
	 * @return String
	 */
	function getStyles(){
		return getRenderer().renderView( view = "styles", module = "cbwire", args = { settings : getSettings() } );
	}

	/**
	 * Returns the JS to be placed in our HTML body.
	 *
	 * @return String
	 */
	function getScripts(){
		return getRenderer().renderView( view = "scripts", module = "cbwire", args = { settings : getSettings() } );
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
		return "window.Livewire.find( '#getLastRenderedId()#' ).entangle( '#arguments.prop#' )";
	}

	/**
	 * Returns the full path to a component.
	 *
	 * @componentName String | Name of the cbwire component.
	 */
	function getRootComponentPath( required componentName ){
		var appMapping = getAppMapping();
		var wireRoot = ( len( appMapping ) ? appMapping & "." : "" ) & getWiresLocation();
		var componentPath = reFindNoCase( appMapping & "\.", arguments.componentName ) ? arguments.componentName : wireRoot & "." & arguments.componentName;
		var currentModule = getCurrentRequestModule();

		if ( currentModule.len() && currentModule != "cbwire" ) {
			// incoming request is from a module

			// if request is already targeting a module wire 
			if( left( componentPath, len( wireRoot ) ) != wireRoot ){
				return componentPath;
			}
			
			// default componentPath to module wire path
			componentPath = currentModule & "." & componentPath;

			var moduleWiresPath = moduleService.getModuleRegistry()[ currentModule ].physicalPath & "/" & currentModule & "/" & getWiresLocation();
			var wireName = reReplace( listLast( componentPath, "." ), "[^\w.\-]", "", "all" );
			// check if module component exists and if it does not, look in root wires location
			if( !fileExists( moduleWiresPath & "/" & wireName & ".cfc" ) && !fileExists( moduleWiresPath & "/" & wireName & ".cfm" ) ){
				var wireRootPath = getController().getappRootPath() & "/" & getWiresLocation();
				if( fileExists( wireRootPath & "/" & wireName & ".cfc" ) || fileExists( wireRootPath & "/" & wireName & ".cfm" ) ){
					// component exists in root wires location, use it
					componentPath = ( len( getAppMapping() ) ? getAppMapping() & "." : "" ) & getWiresLocation() & "." & wireName;
				}else{
					throw( type="ModuleNotFound", message = "CBWIRE cannot locate the wire using '" & componentPath & "'." );
				}
			}
			
		}
		return componentPath;
	}

	/**
	 * Returns a cbwire componentn.
	 *
	 * @componentName String | Name of the cbwire component.
	 *
	 * @return Component
	 */
	function getRootComponent( required componentName, required initialRender ){
		var componentPath = getRootComponentPath( arguments.componentName );

		try {
			return getWireBox().getInstance( componentPath );
		} catch ( Injector.InstanceNotFoundException e ) {
			var singleFileComponent = getSingleFileComponentBuilder()
				.setInitialRender( arguments.initialRender )
				.build( componentPath, arguments.componentName, getCurrentRequestModule() );

			if ( isNull( singleFileComponent ) ) {
				rethrow;
			}

			return singleFileComponent;
		}
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
	function getComponentInstance( componentName, initialRender = true ){
		// Determine our component location from the cbwire settings.
		var wiresLocation = getWiresLocation();

		if ( find( "@", arguments.componentName ) ) {
			// This is a module reference, find in our module
			var params = listToArray( arguments.componentName, "@" );
			if ( params.len() != 2 ) {
				throw( type="ModuleNotFound", message = "CBWIRE cannot locate the module or component using '" & arguments.componentName & "'." );
			}
			// reuse the getRootComponent() method since getModuleComponentPath() returns dot notation path to wire component
			var comp = getRootComponent( getModuleComponentPath( params[ 1 ], params[ 2 ] ), arguments.initialRender );
		} else {
			// Look in our root folder for our cbwire component
			var comp = getRootComponent( arguments.componentName, arguments.initialRender );
		}

		return comp;
	}

	/**
	 * Returns the full dot notation path to a modules component.
	 *
	 * @path String | Name of the cbwire component.
	 * @module String | Name of the module to look for wire in.
	 */
	function getModuleComponentPath( path, module ) {
		var moduleConfig = moduleService.getModuleConfigCache();
		var moduleRegistry = moduleService.getModuleRegistry();
		
		if ( !moduleConfig.keyExists( module ) ) {
			throw( type="ModuleNotFound", message = "CBWIRE cannot locate the module '" & arguments.module & "'.")
		}

		// If there is a dot in our path, then we are referencing a folder within a module.
		// If not, then use the default wire location.
		var moduleComponentPath = arguments.path contains "." ?
			moduleRegistry[ module ].invocationPath & "." & module & "." & arguments.path :
			moduleRegistry[ module ].invocationPath & "." & module & "." & getWiresLocation() & "." & arguments.path;

		return moduleComponentPath;
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
			.startup( initialRender = false )
			.hydrate()
			.subsequentRenderIt( event=event, rc=rc, prc=prc );
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

	/**
	 * Instantiates our cbwire component, mounts it,
	 * and then calls it's internal renderIt() method.
	 *
	 * @componentName String | The name of the component to load.
	 * @parameters Struct | The parameters you want mounted initially.
	 * @key String | The key to use for the component.
	 *
	 * @return Component
	 */
	function wire( componentName, parameters = {}, key = "" ){
		var comp = getComponentInstance( arguments.componentName ).startup();

		if ( len( arguments.key ) ) {
			comp.setId( arguments.key );
		}
 		return comp
 			.mount( arguments.parameters )
 			.renderIt();
 	}

	function getConcern( concern ){
		return getWirebox().getInstance( arguments.concern & "Concern@cbwire" );
	}

	/**
	 * Returns the module of the current request.
	 *
	 * @return string
	 */
	function getCurrentRequestModule(){
		var rc = requestService.getContext().getCollection();
		return structKeyExists( rc, "fingerprint" ) ? rc.fingerprint.module : getRequestService()
			.getContext()
			.getCurrentModule();
	}
	
	/**
	 * Returns the app mapping.
	 *
	 * @return string
	 */
	function getAppMapping(){
		return getController().getSetting( "AppMapping" );
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
	 * Returns the last rendered id.
	 *
	 * @return string
	 */
	function getLastRenderedId(){
		return getRequestService().getContext().getPrivateValue( "cbwire_lastest_rendered_id" );
	}

	/**
	 * Returns the renderer.
	 *
	 * @return Renderer
	 */
	function getRenderer(){
		return getController().getRenderer();
	}

	/**
	 * Returns the cbwire wiresLocation setting.
	 * Defaults to 'wires'
	 *
	 * @return String
	 */
	function getWiresLocation(){
		return structKeyExists( getSettings(), "wiresLocation" ) ? getSettings().wiresLocation : "wires";
	}

}
