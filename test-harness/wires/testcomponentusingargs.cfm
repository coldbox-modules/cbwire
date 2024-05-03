<cfoutput>
    <div>
        <h1>Modules</h1>

        <p>Number Of Modules: #args.modules.len()#</p>

        <cfif args.modules.len()>
            <ul>
                <cfloop array="#args.modules#" index="module">
                    <li>#module#</li>
                </cfloop>
            </ul>
        </cfif>
    </div>
</cfoutput>