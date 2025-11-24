<cfscript>
    // @startWire
    data = {
		"title": {
			"label" : "CBWIRE Rocks!"
		},
        "newValue": "",
        "oldValue": "",
		"modules": {
			"names" : [
				"Module 1",
				"Module 2",
				"Module 3"
			]
		}
    };

    function onUpdatetitle_label( value, oldValue ) {
        data.title.label = arguments.value;
        data.newValue = arguments.value;
        data.oldValue = arguments.oldValue;
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <h1>Title: #title.label#</h1>
        <p>New Value: #newValue#</p>
        <p>Old Value: #oldValue#</p>
        <cfif modules.names.len()>
            <ul>
                <cfloop array="#modules.names#" index="module">
                    <li>#module#</li>
                </cfloop>
            </ul>
        </cfif>

    </div>
</cfoutput>