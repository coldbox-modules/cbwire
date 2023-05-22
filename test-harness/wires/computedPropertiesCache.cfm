<cfoutput>
    <div>
        <h1>Computed Properties Cache</h1>
        <h2>#getTick()#</h2>
        <h2>#getTick()#</h2>
        <h2>#getTick( false )#</h2>
    </div>
</cfoutput>

<cfscript>
    computed = {
        "getTick": function() {
            sleep( 1000 );
            return getTickCount();
        }
    }
</cfscript>