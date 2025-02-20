<cfoutput>
    <div>
        <div>Title: #args.title#</div>

        <h1>Modules</h1>

        <p>Number Of Modules: #modules.len()#</p>

        <cfif modules.len()>
            <ul>
                <cfloop array="#modules#" index="module">
                    <li>#module#</li>
                </cfloop>
            </ul>
        </cfif>

        #wire( name="TestChildComponent" )#
    </div>
</cfoutput>