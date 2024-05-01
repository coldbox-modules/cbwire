component accessors="true" {

	/**
	 * Holds the CBWIRE component
	 */
	property name="comp";

	/**
	 * Holds the params passed in when finishing upload
	 */
	property name="params";

	/**
	 * Constructor
	 */
	function init( comp, params ){
		setComp( arguments.comp );
		setParams( arguments.params )
	}

	function getBase64(){
		return toBase64( get() );
	}

	function getBase64Src(){
		return "data:#getMimeType()#;base64, #getBase64()#";
	}

	function get(){
		return fileReadBinary( getTemporaryStoragePath() );
	}

	function getTemporaryStoragePath(){
		return expandPath( "./#getMeta().serverFile#" );
	}

	function getMetaPath(){
		return expandPath( "./#getUUID()#.json" );
	}

	function getMeta(){
		if ( !structKeyExists( variables, "meta" ) ) {
			if ( fileExists( getMetaPath() ) ) {
				var metaJSON = fileRead( getMetaPath() );
				variables.meta = deserializeJSON( metaJSON );
			} else {
				return;
			}
		}
		return variables.meta;
	}

	function getSize(){
		return getMeta().fileSize;
	}

	function getMIMEType(){
		return getMeta().contentType & "/" & getMeta().contentSubType;
	}

	function getDataPropertyName(){
		return getParams()[ 1 ];
	}

	function getUUID(){
		return getParams()[ 2 ][ 1 ];
	}

	function isImage(){
		return getMeta().contentType == "image";
	}

	function getPreviewURL(){
		return "/livewire/preview-file/#getUUID()#";
	}

	function destroy(){
		fileDelete( getTemporaryStoragePath() );
		fileDelete( getMetaPath() );
		getComp().reset( getDataPropertyName() );
	}

}
