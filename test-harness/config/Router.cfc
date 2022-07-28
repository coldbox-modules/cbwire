component {

	function configure(){
		// Your Application Routes
		route( pattern="/examples/index", target="examples.index" );
		route( pattern="/examples/wireStyles", target="examples.wireStyles" );
		route( pattern="/examples/wireScripts", target="examples.wireScripts" );
		route( pattern="/examples/passParameters", target="examples.passParameters" );
		route( pattern="/examples/passedParametersProvidedToMount", target="examples.passedParametersProvidedToMount" );
		route( pattern="/examples/:component", target="examples.run" );
	}

}
