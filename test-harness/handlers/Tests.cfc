/**
 * Handler for testing missing layout tags
 */
component {

	function testMissingHeadTag( event, rc, prc ) {
		event.setLayout( "MissingHeadTag" );
		event.setView( "tests/missingtags" );
	}

	function testMissingBodyTag( event, rc, prc ) {
		event.setLayout( "MissingBodyTag" );
		event.setView( "tests/missingtags" );
	}

	function testMissingBothTags( event, rc, prc ) {
		event.setLayout( "MissingBothTags" );
		event.setView( "tests/missingtags" );
	}

}
