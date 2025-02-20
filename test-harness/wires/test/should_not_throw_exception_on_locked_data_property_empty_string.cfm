<cfoutput>
    <div>
        <h1>Should Not Throw Exception</h1>
		<p>When a locked property is an empty string the wire should ignore continue.</p>
		<p>Locked Property Value: #lockedPropertyKey#</p>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "lockedPropertyKey": "I AM NOT LOCKED!"
    };

	locked = "";

    // @endWire
</cfscript>