<cfoutput>
    <div>
        <h1>Should track scripts and assets</h1>
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

<cbwire:assets>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css">
</cbwire:script>