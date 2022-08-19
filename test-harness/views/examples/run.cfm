<cfoutput>
    <div class="example">
        <h2>Example</h2>
        #wire( rc.component )#
    </div>
    #renderView( view="/wires/showCode", args={
        wireComponent: rc.component
    } )#
</cfoutput>