<cfscript>
    componentCode = fileRead( expandPath( './wires/#args.wireComponent#.cfc' ) );
    templateCode = fileRead( expandPath( './views/wires/#lCase( args.wireComponent )#.cfm'))
</cfscript>

<cfoutput>
    <hr>
    <h2 class="pt-4">Component Code</h2>
    <pre class="code"><code>#htmlEditFormat( componentCode )#</code></pre>
    <h2 class="pt-4">Template Code</h2>
    <pre class="code"><code>#htmlEditFormat( templateCode )#</code></pre>
</cfoutput>