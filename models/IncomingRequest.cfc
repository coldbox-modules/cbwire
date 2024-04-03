component accessors="true" singleton {

    /*
    * Inject the component loader to get the component instance.
    */
    property name="componentLoader" inject="ComponentLoader@cbwire";

	/**
	 * Primary entry point for cbwire requests.
	 *
	 * Currently uses /livewire URI to support Livewire JS.
	 *
	 * URI: /livewire/messages/:wireComponent
	 */
	function handle( event, rc, prc ){
		return componentLoader.load( rc.wireComponent )
			.startup( initialRender = false )
			.hydrate()
			.subsequentRenderIt( event=event, rc=rc, prc=prc );
	}
}