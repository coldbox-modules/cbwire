<cfoutput>
    <div>
        <h1>Lazy Loading</h1>

        <div style="margin-top:500px">
            #wire( name="SlowComponent", params={ "sleepTime": 1000 }, lazy=true )#
        </div>
    </div>
</cfoutput>