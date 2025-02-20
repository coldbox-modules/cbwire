<cfoutput>
    <div>
        <h1>Should Throw Exception on Locked Property</h1>
		<p>When a property is locked with an string (single value), it should throw an exception when trying to set the provided key.</p>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "lockedPropertyKey": "I AM LOCKED!"
    };

	locked = "lockedPropertyKey";

    // @endWire
</cfscript>