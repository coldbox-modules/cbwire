<cfscript>
    variables.entangle = function( required prop ) {
        var cbwireService = application.wirebox.getInstance( "CBWireService@cbwire" );
        return cbwireService.entangle( argumentCollection=arguments );
    };
    variables.args = attributes.args;

    structAppend( variables, attributes.args );

    structAppend( variables, attributes.args.computed );

    include "#attributes.cbwireTemplate#";
</cfscript>