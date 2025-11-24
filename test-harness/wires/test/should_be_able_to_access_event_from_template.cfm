<cfoutput>
    <div>
        <p>Event is object: #isObject( event ) ? 'true' : 'false'#</p>
        <p>Request collection is struct: #isStruct( event.getCollection() ) ? 'true' : 'false'#</p>
    </div>
</cfoutput>
