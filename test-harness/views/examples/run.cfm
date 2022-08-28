<cfoutput>
    <h2 class="pt-4">Result</h2>
    <div class="example">
        #wire( rc.component )#
    </div>
    #renderView( view="/wires/showCode", args={
        wireComponent: rc.component
    } )#
</cfoutput>