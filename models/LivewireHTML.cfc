component singleton{

	property name="renderer" inject="coldbox:renderer";

	/**
	 * Returns the styles to be placed in HTML head
	 */
	function getStyles(){
		return variables.renderer.renderView(
			view   = "styles",
			module = "cblivewire"
		);
	}

	/**
	 * Returns the JS to be placed in HTML body
	 */
	function getScripts(){
		return variables.renderer.renderView(
			view   = "scripts",
			module = "cblivewire"
		);
	}

}
