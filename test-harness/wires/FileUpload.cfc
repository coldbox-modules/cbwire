component extends="cbwire.models.Component" {

    data = {
        "photo": "",
        "photos": []
    };

    function save() {
        // s3.put( data.myFile.get() );
        if ( isObject( data.photo ) ) {
            data.photo.destroy();
        }
    }

    function update() {
        
    }
}