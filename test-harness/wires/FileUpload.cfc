component extends="cbwire.models.Component" {

    data = {
        "myFile": ""
    };

    function save() {
        // s3.put( data.myFile.get() );
        if ( isObject( data.myFile ) ) {
            data.myFile.destroy();
        }
    }
}