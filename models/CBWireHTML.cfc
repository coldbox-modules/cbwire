/**
 * Handles rendering the CSS and JavaScript that is placed in our layout so that cbwire can function.
 */
component singleton {

	/**
	 * Injected ColdBox Renderer for rendering operations.
	 */
	property name="renderer" inject="coldbox:renderer";

	/**
	 * Injected ColdBox settings
	 */
	property name="settings" inject="coldbox:moduleSettings:cbwire";

	/**
	 * Injected RequestService so that we can access the current ColdBox RequestContext.
	 */
	property name="requestService" inject="coldbox:requestService";

	/**
	 * Returns the JS to be placed in our HTML body.
	 *
	 * @return String
	 */
	function getScripts(){
		return variables.renderer.renderView( view = "scripts", module = "cbwire", args = { settings : settings } );
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
		var lastComponentID = getEvent().getPrivateValue( "cbwire_lastest_rendered_id" );
		return "window.Livewire.find( '#lastComponentID#' ).entangle( '#arguments.prop#' )";
	}

	/**
	 * Return our request context.
	 *
	 * @returns RequestContext
	 */
	function getEvent(){
		return variables.requestService.getContext();
	}

}
