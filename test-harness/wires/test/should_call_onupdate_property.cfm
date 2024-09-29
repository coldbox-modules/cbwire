<cfoutput>
    <div>
        <h1>Should call onupdate property</h1>
        <p>CBWIRE Version: #cbwireVersion#</p>
        <p>New Value: #newValue#</p>
        <p>Old Value: #oldValue#</p>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "cbwireVersion": 3,
        "newValue": "",
        "oldValue": ""
    };

    function onUpdateCBWIREVersion( value, oldValue ) {
        data.cbwireVersion = arguments.value;
        data.newValue = arguments.value;
        data.oldValue = arguments.oldValue;
    }
    // @endWire
</cfscript>