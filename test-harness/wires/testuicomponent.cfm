<cfoutput>
<div>
    <h1>#args.message#</h1>
    <p>Count #args.computed.counter()#</p>
    <cfif args.showButton>
        <div><button>The button</button></div>
    </cfif>
</div>
</cfoutput>