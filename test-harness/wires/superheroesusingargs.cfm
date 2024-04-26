<cfoutput>
    <div>
        <h1>Super Heroes</h1>

        <p>Number Of Heroes: #args.heroes.len()#</p>

        <cfif args.heroes.len()>
            <ul>
                <cfloop array="#args.heroes#" index="hero">
                    <li>#hero#</li>
                </cfloop>
            </ul>
        </cfif>

        <cfif showStats>
            #wire( "SuperHeroStats", {}, "super-hero" )#
            #wire( "SuperHeroStats" )#
        </cfif>
    </div>
</cfoutput>