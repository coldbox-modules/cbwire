component singleton {

	/* 
		Uploads all files from the request to the specified destination.
		Each file is saved to a unique file name.
		Returns a list of the paths to the saved files.

		@return void
	*/
	function handle( required event, required rc, required prc ){
		var results = fileUploadAll( destination = expandPath( "/" ), onConflict = "makeUnique" );
		var paths = results.map( function( result ){
			var id = createUUID();
			fileWrite( expandPath( "/#id#.json" ), serializeJSON( result ) );
			return id;
		} );
		return { "paths" : paths };
	}
}