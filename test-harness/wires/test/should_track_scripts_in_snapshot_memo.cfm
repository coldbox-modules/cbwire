<cfoutput>
    <div>
        <h1>Should track scripts</h1>
    </div>
</cfoutput>

<cfscript>
    // @startWire

    // @endWire
</cfscript>

<cbwire:script>
    <script>
        console.log('This should be tracked');
    </script>
</cbwire:script>

<cbwire:script>
    <script>
        console.log('This should be tracked also');
    </script>
</cbwire:script>