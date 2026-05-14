<cfoutput>
    <div>
        <cfif datePart( "h", now() ) lt 12 >
            <p>Good Morning and hello CBWire Developer from a two file wire in a module!</p>
        <cfelse>
            <p>Good Afternoon and hello CBWire Developer from a two file wire in a module!</p>
        </cfif>
    </div>
</cfoutput>