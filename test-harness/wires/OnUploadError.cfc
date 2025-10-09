component extends="cbwire.models.Component" {

    data = {
        "uploadErrored": false,
        "erroredPropertyName": ""
    };

    function onUploadError( name ) {
        data.uploadErrored = true;
        data.erroredPropertyName = arguments.name;
    }

}
