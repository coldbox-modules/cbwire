component extends="cbwire.models.Component" {

    data = {
        "photo": ""
    };

    function save() {
        // s3.put( data.myFile.get() );
        if ( isObject( data.photo ) ) {
            data.photo.destroy();
        }
    }
}