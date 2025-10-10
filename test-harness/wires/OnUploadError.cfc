component extends="cbwire.models.Component" {

    data = {
        "uploadErrored": false,
        "erroredPropertyName": "",
        "errorInfo": "",
        "isMultiple": false
    };

    function onUploadError( property, errors, multiple ) {
        data.uploadErrored = true;
        data.erroredPropertyName = arguments.property;
        data.errorInfo = isNull( arguments.errors ) ? "null" : "has errors";
        data.isMultiple = arguments.multiple;
    }

}
