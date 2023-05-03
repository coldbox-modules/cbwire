/**
 * Handles rendering the CSS and JavaScript that is placed in our layout so that cbwire can function.
 */
component accessors="true" singleton {

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

}
