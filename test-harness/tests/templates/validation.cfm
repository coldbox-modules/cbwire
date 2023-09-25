<cfoutput>
    <div>
        <cfif validation.hasErrors( "email" )>
            <div>#validation.getAllErrors( "email" ).first()#</div>
        </cfif>
    </div>
</cfoutput>