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