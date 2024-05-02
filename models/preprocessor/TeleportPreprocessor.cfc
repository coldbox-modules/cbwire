/**
 * This component is responsible for handling the preprocessing of content that contains teleport directives.
 * It replaces the @teleport(selector) syntax with <template x-teleport="selector"> and @endteleport with </template>.
 */
component {

    function handle( content ) {
        // Replace @teleport( selector ) with <template x-teleport="selector">
        // This handles optional spacing, and both single and double quotes around the selector
        arguments.content = arguments.content.reReplaceNoCase( "@teleport\s*\(\s*['""]?([^)'""\s]+)['""]?\s*\)", "<template x-teleport=""\1"">", "all" );
        
        // Replace @endteleport with </template>
        arguments.content = arguments.content.replaceNoCase( "@endteleport", "</template>", "all" );
        
        // Return the modified content
        return arguments.content;
    }
}
