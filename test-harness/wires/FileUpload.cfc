component extends="cbwire.models.Component" {

    data = {
        "myFile": ""
    };

    function save() {
        return;
        // s3.put( data.myFile.get() );
        if ( isObject( data.myFile ) ) {
            data.myFile.destroy();
            reset( "myFile" );
        }
    }
}