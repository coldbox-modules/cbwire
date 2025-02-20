<cfoutput>
    <div>
        <h1>Should Not Throw Exception</h1>
		<p>When a locked property is a data type other than an array, string/list the wire should ignore continue.</p>
		<p>Locked Property Value: #lockedPropertyKey#</p>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "lockedPropertyKey": "I AM NOT LOCKED!"
    };

	locked = { "lockedPropertyKey" : "someValue" };

    // @endWire
</cfscript>