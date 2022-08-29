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
    function init( comp, params ) {
        setComp( arguments.comp );
        setParams( arguments.params )
    }

    function getBase64() {
        return toBase64( get() );
    }

    function getBase64Src() {
        return "data:#getMimeType()#;base64, #getBase64()#";
    }

    function get() {
        return fileReadBinary( getTemporaryStoragePath() );
    }

    function getTemporaryStoragePath() {
        return expandPath( "./#getMeta().serverFile#");
    }

    function getMetaPath() {
        return expandPath( "./#getUUID()#.json");
    }

    function getMeta() {
        if ( !structKeyExists( variables, "meta" ) ) {
            var metaJSON = fileRead( getMetaPath() );
            variables.meta = deserializeJson( metaJSON );
        }
        return variables.meta;
    }

    function getSize() {
        return getMeta().fileSize;
    }

    function getMIMEType() {
        return getMeta().contentType & "/" & getMeta().contentSubType;
    }

    function getUUID() {
        return getParams()[ 2 ][ 1 ];
    }

    function isImage() {
        return getMeta().contentType == "image";
    }

    function getTemporaryURL() {
        return "/livewire/preview-file/#getUUID()#";
    }

    function destroy() {
        fileDelete( getMetaPath() );
        fileDelete( getTemporaryStoragePath() );
    }
}