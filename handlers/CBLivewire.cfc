component {

    /**
    * Primary entry point for subsequent livewire requests after 
    * initial component rendering
    *
    * URI: /livewire/messages/:component
    */
	function index( event, rc, prc ){
		var livewireComponent = wirebox.getInstance(
			name          = rc.livewireComponent,
			initArguments = { event : event }
		);
		livewireComponent.hydrate( rc );
		return livewireComponent.getSubsequentPayload( rc );
	}

}