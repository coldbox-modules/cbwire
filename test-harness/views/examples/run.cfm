<cfoutput>
	<h2 class="mt-4">Example</h2>
    #wire( rc.component )#
    #renderView( view="/wires/showCode", args={
        wireComponent: rc.component
    } )#
</cfoutput>