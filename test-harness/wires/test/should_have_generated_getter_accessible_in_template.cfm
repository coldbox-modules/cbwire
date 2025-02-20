<cfscript>
    // @startWire
    data = {
        "name": "John",
        "age": 30,
        "city": "New York"
    };
    // @endWire
</cfscript>


<cfoutput>
    <div>
        <p>Name: #getName()#</p>
        <p>Age: #getAge()#</p>
        <p>City: #getCity()#</p>
    </div>
</cfoutput>