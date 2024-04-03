component singleton {

	/*
		Builds a binary preview for an uploaded file.
		@return void
	*/
	function handle( required event, required rc, required prc ){
		var uuid = event.getValue( "uploadUUID", "" );
		if ( !len( uuid ) ) {
			return event.noRender();
		}

		var metaJSON = deserializeJSON( fileRead( expandPath( "./#uuid#.json" ) ) );
		var contents = fileReadBinary( expandPath( "./#metaJSON.serverFile#" ) );
		event
			.sendFile(
				file = contents,
				disposition = "inline",
				extension = metaJSON.serverFileExt,
				mimeType = "#metaJSON.contentType#/#metaJSON.contentSubType#"
			)
			.noRender();
	}
}