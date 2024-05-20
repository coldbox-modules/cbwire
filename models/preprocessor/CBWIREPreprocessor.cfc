/**
 * This component is responsible for handling the preprocessing of content that contains cbwire tags.
 * It finds all the cbwire tags in the content, extracts the component name and additional arguments,
 * checks for any malformed attributes, and replaces the cbwire tags with the appropriate wire tags.
 * The resulting content is then returned.
 */
component singleton {

    function handle( content ) {
        // Find all the cbwire tags in the content.
        local.pattern = "<cbwire:(\w+)\s*(.*?)\/?>";
        local.argsPattern = "(:)*([A-Za-z0-9]+)\s*=\s*['""]+([A-Za-z0-9]+)['""]+";
        local.instanceMatches = reMatchNocase(local.pattern, content);
        
        // Loop over the matches and replace them with the appropriate content.
        local.instanceMatches.each( function( _match ) {
            // Extract the component name and additional arguments from the match.
            local.regexMatches = reFindNoCase( pattern, _match, 1, true );
            local.componentName = local.regexMatches.match[ 2 ];
            local.additionalArgs = local.regexMatches.match[ 3 ];
            
            // Check if additionalArgs is malformed.
            if (len(trim(local.additionalArgs)) && !reFindNoCase(argsPattern, local.additionalArgs)) {
                throw( type="CBWIREParseException", message="Parsing error: unable to process cbwire tag due to malformed attributes.");
            }
            
            // Look for params in the additionalArgs.
            local.argMatches = reMatchNoCase( argsPattern, local.additionalArgs );
            
            // Start our params string
            local.paramsString = "{";
            
            // Loop over the arg matches
            local.argMatches.each( function( _argMatch, _index ) {
                local.regexMatches = reFindNoCase( argsPattern, _argMatch, 1, true );
                
                // Determine if we are passing this as a string or a variable.
                // Unfortuately, we can only do a try catch here because isNull() check doesn't work.
                // Trust me, I don't like it either. - Grant
                local.isExpression = false;
                try {
                    local.isExpression = !isNull( local.regexMatches.match[ 2 ] ) && local.regexMatches.match[ 2 ] == ":";
                } catch ( any e ) {}
                
                paramsString &= local.isExpression ? " #local.regexMatches.match[ 3 ]#=#local.regexMatches.match[ 4 ]#" : " #local.regexMatches.match[ 3 ]#='#local.regexMatches.match[ 4 ]#'";
                
                // If we are not on the last arg, add a comma.
                if ( _index < arrayLen( argMatches ) ) {
                    paramsString &= ",";
                }
            } );
            
            // End our params string
            paramsString &= " }";
            
            // Replace the cbwire tag with the wire tag.
            content = content.replaceNoCase( _match, "##wire( name=""#local.componentName#"", params=#paramsString#, lazy=false )##" );
        } );

        return content;
    }
}