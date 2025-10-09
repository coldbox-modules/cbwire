<cfscript>
    // @startWire
    data = {
        "uploadErrored": false,
        "erroredPropertyName": ""
    };
    
    function onUploadError( name ) {
        data.uploadErrored = true;
        data.erroredPropertyName = arguments.name;
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <div>Upload Errored: #uploadErrored#</div>
        <div>Errored Property Name: #erroredPropertyName#</div>
    </div>
</cfoutput>
