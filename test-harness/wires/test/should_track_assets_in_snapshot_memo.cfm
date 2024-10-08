<cfoutput>
    <div>
        <h1>Should track assets in snapshot memo</h1>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    function placeholder() {
        return "<div>This is a placeholder</div>";
    }
    // @endWire
</cfscript>

<cbwire:assets>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
</cbwire:assets>