<cfscript>
    // @startWire
    data = {
        "menu": [
            {
                "name": "Home",
                "link": "index.cfm"
            },
            {
                "name": "About",
                "link": "about.cfm"
            },
            {
                "name": "Contact",
                "link": "contact.cfm"
            }
        ]
    };

    function setFirst() {
        data.menu[1].name = "Home Updated";
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <ul>
            <cfloop array="#data.menu#" index="item">
                <li><a href="#item.link#">#item.name#</a></li>
            </cfloop>
        </ul>
    </div>
</cfoutput>