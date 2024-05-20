<cfscript>
    componentPath = expandPath( './wires/#lCase( data.component )#.cfc');
    templatePath = expandPath( './wires/#lCase( data.component )#.cfm');
    //viewCode = '<cfoutput>##wire( "#wire#" )##</cfoutput>';
    viewCode = fileRead( templatePath );
    componentCode = fileExists( componentPath ) ? fileRead( componentPath ) : "";
    //componentCode = "<!--- Path: /views/wires/#lCase( wire )#.cfm --->" & chr( 10 ) & componentCode;
</cfscript>

<cfoutput>
    <div>
        <pre><code class="code-preview language-js">// File: ./wires/Test.cfc#chr( 10 )##htmlEditFormat( componentCode )#</code></pre>
        <pre><code class="code-preview language-html">&lt;!-- File: ./wires/test.cfm --&gt;#chr(10)##htmlEditFormat( viewCode )#</code></pre>
    </div>
</cfoutput>