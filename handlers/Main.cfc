component {

    /**
    * Primary entry point for subsequent livewire requests after 
    * initial component rendering
    *
    * URI: /livewire/messages/:component
    */
	function index( event, rc, prc ){
		return variables.wirebox
			.getInstance( "cbLivewire.models.LivewireRequest" )
			.withComponent( arguments.rc.livewireComponent )
			.$hydrate()
			.$getMemento();
	}

}