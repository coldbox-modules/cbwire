<cfoutput>
    <div>
        <div>Title: #args.title#</div>

        <h1>Super Heroes</h1>

        <p>Number Of Heroes: #heroes.len()#</p>

        <cfif heroes.len()>
            <ul>
                <cfloop array="#heroes#" index="hero">
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