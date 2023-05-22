<cfscript>
    componentPath = expandPath( './wires/#lCase( args.wireComponent )#.cfm')
    viewCode = '<cfoutput>##wire( "#args.wireComponent#" )##</cfoutput>';
    componentCode = fileExists( componentPath ) ? fileRead( componentPath ) : "";
    componentCode = "<!--- Path: /views/wires/#lCase( args.wireComponent )#.cfm --->" & chr( 10 ) & componentCode;
</cfscript>

<cfoutput>
    <h2 class="pt-4">View / Layout</h2>
    <pre><code class="language-html">#htmlEditFormat( viewCode )#</code></pre>
    <h2 class="pt-4">Component</h2>
    <pre><code class="language-html">#htmlEditFormat( componentCode )#</code></pre>
</cfoutput>