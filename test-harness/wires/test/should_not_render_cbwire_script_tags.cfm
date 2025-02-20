<cfoutput>
    <div>
        <h1>Should not render cbwire script tags</h1>
    </div>
</cfoutput>

<cfscript>
    // @startWire

    // @endWire
</cfscript>

<cbwire:script>
    <script>
        console.log('This should not be rendered');
    </script>
</cbwire:script>