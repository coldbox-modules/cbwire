/**
 * This is the file entity that is used to represent a file that has been uploaded
 * to the server. It is used to store the file in a temporary location and to
 * provide access to the file's metadata.
 */
component {

    // Inject module settings
    property name="moduleSettings" inject="coldbox:modulesettings:cbwire";

    /**
     * Constructor
     */
    function load( wire, dataPropertyName, uuid ){
        variables.wire = arguments.wire;
        variables.dataPropertyName = arguments.dataPropertyName;
        variables.uuid = arguments.uuid;

        var metaPath = getMetaPath();

        if ( fileExists( metaPath ) ) {
            var metaJSON = fileRead( metaPath );
            variables.meta = deserializeJSON( metaJSON );
        } else {
            throw( type="CBWIREException", message="File upload metadata not found." );
        }

        variables.temporaryStoragePath = getCanonicalPath( variables.meta.serverDirectory & "/#variables.meta.serverFile#" );
        return this;
    }

    /**
     * Returns the base64 representation of the file
     */
    function getBase64(){
        return toBase64( get() );
    }

    /**
     * Returns the base64 src of the file
     */
    function getBase64Src(){
        return "data:#getMimeType()#;base64, #getBase64()#";
    }

    /**
     * Returns the binary for the uploaded file
     */
    function get(){
        return fileReadBinary( variables.temporaryStoragePath );
    }

    /**
     * Returns the file's size
     */
    function getSize(){
        return variables.meta.fileSize;
    }

    /**
     * Returns the file's MIME type
     */
    function getMIMEType(){
        return variables.meta.contentType & "/" & variables.meta.contentSubType;
    }

    /**
     * Returns true if the uploaded file is an image
     */
    function isImage(){
        return variables.meta.contentType == "image";
    }

    /**
     * Returns the file's preview URL
     */
    function getPreviewURL(){
        return "/cbwire/preview-file/#variables.uuid#";
    }

    /**
     * Returns the temporary file path
     */
    function getTemporaryStoragePath(){
        return variables.temporaryStoragePath;
    }

    /**
     * Deletes the file in temporary storage and the metadata file
     */
    function destroy(){
        fileDelete( variables.temporaryStoragePath );
        fileDelete( getMetaPath() );
        variables.wire.reset( variables.dataPropertyName );
    }

    /**
     * Serialize the file upload
     */
    function serializeIt(){
        return "fileupload:" & variables.uuid;
    }

    /**
     * Return the meta data for the upload
     */
    function getMeta(){
        return variables.meta;
    }

    /**
     * Returns the path to the temp directory (mockable in tests)
     */
    function getUploadTempDirectory(){
        return getCanonicalPath( variables.moduleSettings.moduleRootPath & "models/tmp" );
    }

    /**
     * Returns the full path to the metadata file (mockable in tests)
     */
    function getMetaPath(){
        return getCanonicalPath( getUploadTempDirectory() & "/#variables.uuid#.json" );
    }
}
