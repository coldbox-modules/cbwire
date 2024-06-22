<cfscript>
    // @startWire
    data = {
        "name": "John Doe",
        "copiedName": "",
        "age": 30,
        "city": "New York"
    };

    function onMount() {
        setCopiedName( getName() );
        setName( "Jane Doe" );
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <p>Name: #name#</p>
        <p>Copied name: #copiedName#</p>
    </div>
</cfoutput>