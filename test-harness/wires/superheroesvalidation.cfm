<cfoutput>
    <div>
        <cfif validation.hasErrors()>
            <cfloop array="#validation.getErrors()#" index="error">
                <p>#error.getMessage()#</p>
            </cfloop>
        </cfif>
    </div>
</cfoutput>