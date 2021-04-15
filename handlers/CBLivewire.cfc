component {

    /**
    * Primary entry point for subsequent livewire requests after 
    * initial component rendering
    *
    * URI: /livewire/messages/:component
    */
	function index( event, rc, prc ){
		var livewireRequest = wirebox.getInstance( name="cbLivewire.core.LivewireRequest", initArguments={ event = event } );

		var livewireComponent = wirebox.getInstance(
			name          = rc.livewireComponent,
			initArguments = { livewireRequest : livewireRequest }
		);

		return livewireComponent
			.hydrate()
			.getPayload();
	}

}