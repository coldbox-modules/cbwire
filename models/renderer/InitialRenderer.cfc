component extends="BaseRenderer" {

	/**
	 * A beautiful start.
	 */
	function start( parent, parentCFCPath ){
		setIsInitialRendering( true );
		return super.start( argumentCollection = arguments );
	}

}
