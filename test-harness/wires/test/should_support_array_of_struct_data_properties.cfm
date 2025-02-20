<cfscript>
    // @startWire
    data = [
        "title": "CBWIRE Rocks!",
        "states": []
    ];

    function addState( abr, name ){
        data.states.append( { "name" : name, "abr" : abr } );
    }

    function onMount( params, event, rc, prc ) {
        // Initialize some states
        data.states.append( { "name" : "Maryland", "abr" : "MD" } );
        data.states.append( { "name" : "Virginia", "abr" : "VA" } );
        data.states.append( { "name" : "Florida", "abr" : "FL" } );
        data.states.append( { "name" : "Wyoming", "abr" : "WY" } );
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <div>#args.title#</div>
        <h1>States</h1>
        <p>Number Of States In data.states: #states.len()#</p>
        <cfif states.len() >
            <ul>
                <cfloop index="currentIndex" item="currentState" array="#states#"> 
                    <li>#currentState.abr# : #currentState.name#</li>
                </cfloop>
            </ul>
        </cfif>
    </div>
</cfoutput>