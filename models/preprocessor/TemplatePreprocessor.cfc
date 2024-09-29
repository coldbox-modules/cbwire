component {
    /**
     * Returns content with scripts and assets parsed.
     *
     * @content string | The raw template contents
     * 
     * @return string
     */
    function handle( content ) {
        // Handle <cbwire:script> tags
        content = parseScripts( content );
        // Handle <cbwire:assets> tags
        content = parseAssets( content );
        return content;
    }

    /**
     * Parses <cbwire:script> tags.
     *
     * @content | The raw template contents
     * @counter | Tracks the instances of cbwire:script
     * 
     * @return string
     */
    function parseScripts( content, counter = 1 ) {
        arguments.content = replaceNoCase( arguments.content, "</cbwire:script>", "</" & "cf" & "savecontent>", "one" );
        arguments.content = replaceNoCase( arguments.content, "<cbwire:script>", "<" & "cf" & "savecontent variable=""attributes.returnValues.script#counter#"">", "one" );
        if ( findNoCase( "<cbwire:script>", arguments.content ) ) {
            arguments.content = parseScripts( arguments.content, arguments.counter + 1 );
        }
        return arguments.content;
    }

    /**
     * Parses <cbwire:assets> tags.
     * 
     * @content | The raw template contents
     * @counter | Tracks the instances of cbwire:assets
     * 
     * @return string
     */
    function parseAssets( content, counter = 1 ) {
        if ( counter == 1 ) {
            content = replaceNoCase( content, "</cbwire:assets>", "</" & "cf" & "savecontent>", "all" );
        }
        content = replaceNoCase( content, "<cbwire:assets>", "<" & "cf" & "savecontent variable=""attributes.returnValues.assets#counter#"">", "one");
        if ( findNoCase( "<cbwire:assets>", content ) ) {
            content = parseAssets( content, counter + 1 );
        }
        return content;
    }
}