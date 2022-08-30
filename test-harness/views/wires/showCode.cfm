<cfscript>
    componentPath = expandPath( './wires/#args.wireComponent#.cfc' );
    templatePath = expandPath( './views/wires/#lCase( args.wireComponent )#.cfm')
    viewCode = '<cfoutput>##wire( "#args.wireComponent#" )##</cfoutput>';
    componentCode = fileExists( componentPath ) ? fileRead( componentPath ) : "";
    templateCode = fileExists( templatePath ) ? fileRead( templatePath ) : "";

    componentCode = "// Path: /wires/#args.wireComponent#.cfc" & chr( 10 ) & componentCode;
    templateCode = "<!--- Path: /views/wires/#lCase( args.wireComponent )#.cfm --->" & chr( 10 ) & templateCode;
</cfscript>

<cfoutput>
    <h2 class="pt-4">View / Layout</h2>
    <pre><code class="language-html">#htmlEditFormat( viewCode )#</code></pre>
    <h2 class="pt-4">Component</h2>
    <pre><code class="language-JavaScript">#htmlEditFormat( componentCode )#</code></pre>
    <h2 class="pt-4">Template</h2>
    <pre><code class="language-html">#htmlEditFormat( templateCode )#</code></pre>
</cfoutput>