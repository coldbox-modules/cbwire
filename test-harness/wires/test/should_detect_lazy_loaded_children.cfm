<cfscript>
    // @startWire

    // @endWire
</cfscript>

<cfoutput>
    <div>
        <h1>Parent</h1>
        <!-- start child -->
        #wire( name="test.child_component", lazy=true )#
        <!-- end child -->
    </div>
</cfoutput>