component {

	property name="wirebox" inject="wirebox";
	property name="renderer" inject="coldbox.system.web.Renderer"; // is there a shorter path?


	/**
	 * Returns the styles to be placed in HTML head
	 */
	function getStyles( event, rc, prc ){
		return renderer.renderView(
			view   = "styles",
			module = "cblivewire"
		);
	}

	/**
	 * Returns the JS to be placed in HTML body
	 */
	function getScripts( event, rc, prc ){
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

	function handleRequest( event, rc, prc ){
		var livewireComponent = wirebox.getInstance(
			name          = rc.livewireComponent,
			initArguments = { event : event }
		);
		livewireComponent.hydrate( rc );
		return livewireComponent.getSubsequentPayload( rc );
	}

}
