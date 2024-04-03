component accessors="true" {

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
		var lastRenderedId = getRequestService().getContext().getPrivateValue( "cbwire_lastest_rendered_id" );
		return "window.Livewire.find( '#lastRenderedId#' ).entangle( '#arguments.prop#' )";
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
		var componentLoader = getWirebox().getInstance( "ComponentLoader@cbwire" );
		var comp = componentLoader.load( arguments.componentName ).startup();

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
	 * Returns the renderer.
	 *
	 * @return Renderer
	 */
	function getRenderer(){
		return getController().getRenderer();
	}

}
