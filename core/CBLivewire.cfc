component {

	property name="wirebox" inject="wirebox";
	property name="renderer" inject="Renderer@coldbox";


	/**
	 * Returns the styles to be placed in HTML head
	 */
	function getStyleHTML(){
		return renderer.renderView(
			view   = "styles",
			module = "cblivewire"
		);
	}

	/**
	 * Returns the JS to be placed in HTML body
	 */
	function getScriptHTML(){
		return renderer.renderView(
			view   = "scripts",
			module = "cblivewire"
		);
	}

	/**
	 * Renders a livewire component
	 */
	function render( RequestContext event, componentName ){
		var livewireComponent = wirebox.getInstance(
			name          = "handlers.cblivewire.#componentName#",
			initArguments = { event : event }
		);
		return livewireComponent.render();
	}

}
