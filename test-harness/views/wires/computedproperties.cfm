<cfoutput>
    <div>
        <h1>Welcome To #args.conference#</h1>
        <h2>Speakers</h2>
        <ul>
            <cfloop query="#args.speakers#">
                <li>#firstname# #lastname#</li>
            </cfloop>
        </ul>
    </div>
</cfoutput>