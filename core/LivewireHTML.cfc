component {

	property name="renderer" inject="Renderer@coldbox";

	/**
	 * Returns the styles to be placed in HTML head
	 */
	function getStyles(){
		return renderer.renderView(
			view   = "styles",
			module = "cblivewire"
		);
	}

	/**
	 * Returns the JS to be placed in HTML body
	 */
	function getScripts(){
		return renderer.renderView(
			view   = "scripts",
			module = "cblivewire"
		);
	}

}
