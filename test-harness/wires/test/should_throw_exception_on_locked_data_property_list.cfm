<cfoutput>
    <div>
        <h1>Should Throw Exception on Locked Property</h1>
		<p>When a property is locked with an list, it should throw an exception when trying to set any of the keys in the list.</p>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "lockedPropertyKey": "I AM LOCKED!",
        "lockedPropertyKeyTwo": "I AM ALSO LOCKED!",
        "lockedPropertyKeyThree": "I AM LOCKED AS WELL!"
    };

	locked = "lockedPropertyKeyThree,lockedPropertyKey";

    // @endWire
</cfscript>