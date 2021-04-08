component {

	function configure(){
		// Resources
		resources( "roles" );

		// Your Application Routes
		addRoute( pattern = ":handler/:action?" );
	}

}
