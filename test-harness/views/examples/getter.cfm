<cfset wireComponent = "Getter">

<cfoutput>
    #wire( wireComponent )#
    #renderView( view="/wires/showCode", args={
        wireComponent: wireComponent
    } )#
</cfoutput>