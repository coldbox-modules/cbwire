component {

	function configure(){
		// Your Application Routes
		route( pattern="/examples/index", target="examples.index" );
		route( pattern="/examples/:component", target="examples.run" );
	}

}
