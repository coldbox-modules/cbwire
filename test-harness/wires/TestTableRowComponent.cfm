<cfoutput>
    <tr>
        <td>test table row component</td>
    </tr>
</cfoutput>

<cfscript>
    // @startWire
    data = {};

    function placeholder() {
        return "<tr><td>some placholder</td></tr>";
    }
    // @endWire
</cfscript>