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
        return variables.meta.fileSize;
    }

    /**
     * Returns the file's MIME type.
     *
     * @return string
     */
    function getMIMEType(){
        return variables.meta.contentType & "/" & variables.meta.contentSubType;
    }

    /**
     * Returns true if the uploaded file is an image.
     *
     * @return boolean
     */
    function isImage(){
        return variables.meta.contentType == "image";
    }

    /**
     * Returns the file's preview URL.
     *
     * @return string
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
     * Moves the file from temporary storage to a permanent location.
     * 
     * The metadata file remains in the uploads temp directory to track the upload state,
     * while the actual file is moved to the specified permanent location. This allows
     * the FileUpload object to continue tracking the file even after it's been stored.
     * 
     * @path The destination path where the file should be stored (can be a directory or full file path)
     * @return The absolute path to the stored file
     */
    function store( required string path ){
        var destinationPath = getCanonicalPath( arguments.path );
        
        // Check if destination is a directory
        if ( directoryExists( destinationPath ) ) {
            destinationPath = getCanonicalPath( destinationPath & "/" & variables.meta.serverFile );
        }
        
        // Ensure the destination directory exists
        var destinationDir = getDirectoryFromPath( destinationPath );
        if ( !directoryExists( destinationDir ) ) {
            createDirectoryPath( destinationDir );
        }
        
        // Move the file from temporary to permanent location
        fileMove( variables.temporaryStoragePath, destinationPath );
        
        // Update the temporary storage path to the new location
        variables.temporaryStoragePath = destinationPath;
        
        // Update metadata to reflect new file location
        variables.meta.serverDirectory = destinationDir;
        variables.meta.serverFile = getFileFromPath( destinationPath );
        
        // Update the metadata file (stays in temp directory for upload tracking)
        fileWrite( getMetaPath(), serializeJSON( variables.meta ) );
        
        return destinationPath;
    }

    /**
     * Returns the path to the temp directory (mockable in tests)
     */
    function getUploadTempDirectory(){
        return getCanonicalPath( variables.moduleSettings.uploadsStoragePath );
    }

    /**
     * Returns the full path to the metadata file (mockable in tests)
     */
    function getMetaPath(){
        return getCanonicalPath( getUploadTempDirectory() & "/#variables.uuid#.json" );
    }

    /**
     * Creates a directory path recursively, compatible with Boxlang, ACF, and Lucee
     *
     * @path The directory path to create
     */
    private function createDirectoryPath( required string path ){
        // Build up the path components
        var pathParts = listToArray( arguments.path, "/\" );
        var currentPath = "";

        // Handle absolute paths (starting with / or drive letter)
        if ( left( arguments.path, 1 ) == "/" ) {
            currentPath = "/";
        } else if ( reFind( "^[A-Za-z]:", arguments.path ) ) {
            currentPath = pathParts[ 1 ];
            arrayDeleteAt( pathParts, 1 );
        }

        // Create each directory in the path if it doesn't exist
        for ( var part in pathParts ) {
            if ( len( trim( part ) ) ) {
                currentPath = currentPath & "/" & part;
                if ( !directoryExists( currentPath ) ) {
                    directoryCreate( currentPath );
                }
            }
        }
    }
}
