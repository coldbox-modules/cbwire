<cfscript>
    variables.wire = function( componentName, parameters = {} ) {
        return application.wirebox.getInstance( "CBWireService@cbwire" )
                   .getComponentInstance( arguments.componentName )
                   ._mount( arguments.parameters )
                   ._renderIt();
    };

    variables.entangle = function( required prop ) {
        var cbwireService = application.wirebox.getInstance( "CBWireService@cbwire" );
        return cbwireService.entangle( argumentCollection=arguments );
    };
    variables.args = attributes.args;

    structAppend( variables, attributes.args );

    structAppend( variables, attributes.args.computed );

    include "#attributes.cbwireTemplate#";
</cfscript>