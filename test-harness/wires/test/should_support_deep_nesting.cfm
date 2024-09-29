<cfoutput>
    <div>
        <h1>Should support deep nesting</h1>
        #wire( "test.child1" )#
        #wire( "test.child1" )#
    </div>
</cfoutput>

<cfscript>
    // @startWire

    // @endWire
</cfscript>