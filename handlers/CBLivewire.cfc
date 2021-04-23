component {

    /**
    * Primary entry point for subsequent livewire requests after 
    * initial component rendering
    *
    * URI: /livewire/messages/:component
    */
	function index( event, rc, prc ){
		return wirebox
			.getInstance( "cbLivewire.models..LivewireRequest" )
			.withComponent( rc.livewireComponent )
			.hydrate()
			.getMemento();
	}

}