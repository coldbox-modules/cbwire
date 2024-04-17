<cfoutput>
    <div>
        <h1>Welcome To #conference()#</h1>
        <h2>Speakers</h2>
        <ul>
            <cfloop query="#speakers()#">
                <li>#firstname# #lastname#</li>
            </cfloop>
        </ul>
    </div>
</cfoutput>