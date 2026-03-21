/**
 * My Event Handler Hint
 */
component {

	// Index
	any function index( event, rc, prc ){
		event.setView( "main/index" );
	}

	any function testGenericWireView1( event, rc, prc ){
		/*
			Bypass the need for a view and just call the wireGenericView() helper directly in the handler method
			this will render the specified component in the generic wire view and pass the title and titleTag
			arguments to it as well
		*/
		wireGenericView(
			"genericWireViewTesting.genericTest",
			{},
			{ title = "CBWIRE Test wireGenericView() Helper One", titleTag = "h2" }
		);
	}

	any function testGenericWireView2( event, rc, prc ){
		/*
			Bypass the need for a view and just call the wireGenericView() helper directly in the handler method
			this will render the specified component in the generic wire view and pass the title and titleTag
			arguments to it as well
		*/
		wireGenericView(
			"genericWireViewTesting.genericTest",
			{ "testArgument" : "Test Argument Passed In Succesfully" },
			{ title = "CBWIRE Test wireGenericView() Helper Two", titleTag = "h3" }
		);
	}

	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}
