/**
 * Handles rendering the CSS and JavaScript that is placed in our layout so that cbwire can function.
 */
component singleton {

	/**
	 * Injected ColdBox Renderer for rendering operations.
	 */
	property name="renderer" inject="coldbox:renderer";

	/**
	 * Returns the styles to be placed in our HTML head.
	 *
	 * @return String
	 */
	function getStyles(){
		return variables.renderer.renderView( view = "styles", module = "cbwire" );
	}

	/**
	 * Returns the JS to be placed in our HTML body.
	 *
	 * @return String
	 */
	function getScripts(){
		return variables.renderer.renderView( view = "scripts", module = "cbwire" );
	}

}
