<cfoutput>
    <div>
        <h1>Should Throw Exception on Locked Property</h1>
		<p>When a property is locked with an array, it should throw an exception when trying to set any of the keys in the array.</p>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "lockedPropertyKey": "I AM LOCKED!"
    };

	locked = ["lockedPropertyKey"];

    // @endWire
</cfscript>