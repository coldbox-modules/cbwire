component {

    function handle( content ) {
        return content;
        // // Find all the cbwire tags in the content.
        // local.pattern = "<cbwire:(\w+)\s*(.*?)\/?>";
        // local.result = "";
        // local.instanceMatches = reMatchNocase(local.pattern, content);
        // // Loop over the matches and replace them with the appropriate content.
        // local.instanceMatches.each( function( _match ) {
        //     local.match = findNoCase( _match, content );
        //     local.replacement = "";
        //     content = mid( content, local.match)
        //     writeDump(local.match);
        //     abort;
        //     local.componentName = _match[ 1 ];
        //     local.additionalAttributes = match[ 2 ];
        //     local.component = createObject( "component", "components.#local.componentName#" );
        //     local.result &= local.component.render( local.additionalAttributes );
        // } );
        // writeDump( local );
        // abort;

        // local.componentName= matches.match[ 2 ];
        // local.additionalAttributes = matches.match[ 3 ];

        // writeDump( matches );
        // abort;
   
        // writeDump( matchPos.match.slice( 3, matchPos.match.len()-2 ) );
        // abort;
    }
}