<cfoutput>
    <div>
        <ul>
            <cfloop array="#names()#" index="name">
                <li>#name#</li>
            </cfloop>
        </ul>
    </div>
</cfoutput>