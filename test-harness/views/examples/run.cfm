<cfoutput>
    <div class="example">
        #wire( rc.component )#
    </div>
    #renderView( view="/wires/showCode", args={
        wireComponent: rc.component
    } )#
</cfoutput>