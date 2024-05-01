<cfscript>
    componentPath = expandPath( './wires/#lCase( data.component )#.cfc');
    templatePath = expandPath( './wires/#lCase( data.component )#.cfm');
    //viewCode = '<cfoutput>##wire( "#wire#" )##</cfoutput>';
    viewCode = fileRead( templatePath );
    componentCode = fileExists( componentPath ) ? fileRead( componentPath ) : "";
    //componentCode = "<!--- Path: /views/wires/#lCase( wire )#.cfm --->" & chr( 10 ) & componentCode;
</cfscript>

<cfoutput>
    <h2 class="pt-4">Component</h2>
    <pre><code class="language-html">#htmlEditFormat( componentCode )#</code></pre>

    <pre><code class="language-html">#htmlEditFormat( viewCode )#</code></pre>
</cfoutput>