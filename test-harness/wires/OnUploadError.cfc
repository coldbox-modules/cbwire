component extends="cbwire.models.Component" {

    data = {
        "uploadErrored": false,
        "erroredPropertyName": "",
        "errorInfo": "",
        "isMultiple": false
    };

    function onUploadError( name, errors, multiple ) {
        data.uploadErrored = true;
        data.erroredPropertyName = arguments.name;
        data.errorInfo = isNull( arguments.errors ) ? "null" : "has errors";
        data.isMultiple = arguments.multiple;
    }

}
