component accessors="true" singleton {

	/**
	 * Injected WireBox because DI rocks.
	 */
	property name="wirebox" inject="wirebox";

	/**
	 * Injected ColdBox controller which we will use to access our app and module settings
	 */
	property name="controller" inject="coldbox";

	/**
	 * Module service
	 */
	property name="moduleService" inject="coldbox:moduleService";

	/**
	 * Injected RequestService so that we can access the current ColdBox RequestContext.
	 */
	property name="requestService" inject="coldbox:requestService";

	/**
	 * Injected settings.
	 */
	property name="settings" inject="coldbox:modulesettings:cbwire";

	/**
	 * Inject SingleFileComponentBuilder
	 */
	property name="singleFileComponentBuilder" inject="SingleFileComponentBuilder@cbwire";

	/**
	 * Finds and returns our cbwire component by name, either using
	 * module syntax Component@Module or root sytax, which looks
	 * in the root "wires" folder by default.
	 *
	 * The folder can be overridden with the 'componentLocation' setting.
	 *
	 * @componentName String | The name of the component.
	 * @initialRender Boolean | Whether to render the component immediately.
	 */
	function load( componentName, initialRender = true ){
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
	 * Returns the app mapping.
	 *
	 * @return string
	 */
	private function getAppMapping(){
		return getController().getSetting( "AppMapping" );
	}


	/**
	 * Returns the full dot notation path to a modules component.
	 *
	 * @path String | Name of the cbwire component.
	 * @module String | Name of the module to look for wire in.
	 */
	private function getModuleComponentPath( path, module ) {
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
	 * Returns the cbwire wiresLocation setting.
	 * Defaults to 'wires'
	 *
	 * @return String
	 */
	private function getWiresLocation(){
		var settings = getSettings();
		return settings.keyExists( "wiresLocation" ) ? settings.wiresLocation : "wires";
	}

	/**
	 * Returns a cbwire component.
	 *
	 * @componentName String | Name of the cbwire component.
	 * @initialRender Boolean | Whether to render the component immediately.
	 *
	 * @return Component
	 */
	private function getRootComponent( required componentName, required initialRender ){
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
	 * Returns the full path to a component.
	 *
	 * @componentName String | Name of the cbwire component.
	 */
	private function getRootComponentPath( required componentName ){
		var appMapping = getAppMapping();
		var wireRoot = ( appMapping.len() ? appMapping & "." : "" ) & getWiresLocation();
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
					componentPath = getAppMapping().len() ? getAppMapping() & "." : "" & getWiresLocation() & "." & wireName;
				}else{
					throw( type="ModuleNotFound", message = "CBWIRE cannot locate the wire using '" & componentPath & "'." );
				}
			}
			
		}
		return componentPath;
	}

	/**
	 * Returns the module of the current request.
	 *
	 * @return string
	 */
	private function getCurrentRequestModule(){
		var rc = requestService.getContext().getCollection();
		return structKeyExists( rc, "fingerprint" ) ? rc.fingerprint.module : getRequestService()
			.getContext()
			.getCurrentModule();
	}
}