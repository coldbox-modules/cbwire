/** 
 * This is the file entity that is used to represent a file that has been uploaded
 * to the server. It is used to store the file in a temporary location and to
 * provide access to the file's metadata.
 */
component {

    /**
     * Constructor
     */
    function init( wire, dataPropertyName, uuid ){
        // Our CBWIRe Component
        variables.wire = arguments.wire;
        // The data property name the file upload is for
        variables.dataPropertyName = arguments.dataPropertyName; // getParams()[ 1 ]
        // The UUID of the file upload we provided after the upload was complete
        variables.uuid = arguments.uuid; // getParams()[ 2 ][ 1 ]
        // The file upload metadata JSON file path
        variables.metaPath = expandPath( "./#variables.uuid#.json" );
        // Load the metadata, throw and exception if fails
        if ( fileExists( variables.metaPath ) ) {
            local.metaJSON = fileRead( variables.metaPath );
            variables.meta = deserializeJSON( local.metaJSON );
        } else {
            throw( type="CBWIREException", message="File upload metadata not found." );
        }
        // The file upload temporary storage path
        variables.temporaryStoragePath = expandPath( "./#variables.meta#.serverFile" );
    }

    /**
     * Returns the base64 representation of the file
     * 
     * @return string
     */
    function getBase64(){
        return toBase64( get() );
    }

    /** 
     * Returns the base64 src of the file
     * 
     * @return string
     */
    function getBase64Src(){
        return "data:#getMimeType()#;base64, #getBase64()#";
    }

    /** 
     * Returns the binary for the uploaded file.
     * 
     * @return binary
     */
    function get(){
        return fileReadBinary( variables.temporaryStoragePath );
    }

    /**
     * Returns the file's size.
     * 
     * @return numeric
     */
    function getSize(){
        return getMeta().fileSize;
    }

    /** 
     * Returns the file's MIME type.
     * 
     * @return string
     */
    function getMIMEType(){
        return getMeta().contentType & "/" & getMeta().contentSubType;
    }

    /** 
     * Returns true if the uploaded file is an image. 
     * 
     * @return boolean
     */
    function isImage(){
        return getMeta().contentType == "image";
    }

    /** 
     * Returns the file's preview URL.
     * 
     * @return string
     */
    function getPreviewURL(){
        return "/livewire/preview-file/#variables.uuid#";
    }

    /** 
     * Deletes the file in temporary storage and the metadata file.
     * 
     * @return void
     */
    function destroy(){
        fileDelete( variables.temporaryStoragePath );
        fileDelete( variables.metaPath );
        variables.wire.reset( variables.dataPropertyName );
    }

}