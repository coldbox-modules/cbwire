<cfscript>
    componentPath = expandPath( './wires/#args.wireComponent#.cfc' );
    templatePath = expandPath( './views/wires/#lCase( args.wireComponent )#.cfm')
    componentCode = fileExists( componentPath ) ? fileRead( componentPath ) : "";
    templateCode = fileExists( templatePath ) ? fileRead( templatePath ) : "";
</cfscript>

<cfoutput>
    <h2 class="pt-4">Component Code</h2>
    <pre><code class="language-JavaScript">#htmlEditFormat( componentCode )#</code></pre>
    <h2 class="pt-4">Template Code</h2>
    <pre><code class="language-html">#htmlEditFormat( templateCode )#</code></pre>
</cfoutput>