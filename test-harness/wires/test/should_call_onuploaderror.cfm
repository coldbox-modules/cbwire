<cfscript>
    // @startWire
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
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <div>Upload Errored: #uploadErrored#</div>
        <div>Errored Property Name: #erroredPropertyName#</div>
        <div>Error Info: #errorInfo#</div>
        <div>Is Multiple: #isMultiple#</div>
    </div>
</cfoutput>
