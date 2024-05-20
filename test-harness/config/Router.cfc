component {

	function configure(){
		// Your Application Routes
		route( pattern="/examples/index", target="examples.index" );
		route( pattern="/examples/wireStyles", target="examples.wireStyles" );
		route( pattern="/examples/wireScripts", target="examples.wireScripts" );
		route( pattern="/examples/passParameters", target="examples.passParameters" );
		route( pattern="/examples/passedParametersProvidedToMount", target="examples.passedParametersProvidedToMount" );
		route( pattern="/workshop/Counter", target="workshop.counter" );
		route( pattern="/workshop/AlpineUpload", target="workshop.alpineUpload" );
		route( ":handler/:action?" ).end();
	}

}
