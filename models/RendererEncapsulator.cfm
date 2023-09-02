<cfscript>
	httpRequestData = getHTTPRequestData();

    childWireInstanceIndex = 0;

    serverMemoChildren = httpRequestData.content.len() ? deserializeJson( httpRequestData.content ).serverMemo.children : {};

    variables[ "getInstance" ] = attributes.cbwireComponent.getInstance;

    variables[ "data" ] = attributes.cbwireComponent._getDataProperties();

    variables[ "rc" ] = attributes.event.getCollection();

    variables[ "prc" ] = attributes.event.getPrivateCollection();

    functions = getMetaData( attributes.cbwirecomponent ).functions;
    functions.each( function( cbwireFunction ) {
        variables[ cbwireFunction.name ] = function() {
            return invoke( attributes.cbwireComponent, cbwireFunction.name, arguments );
        };
    } );

    variables.wire = function( componentName, parameters = {} ) {
        childWireInstanceIndex += 1;
        if ( structKeyExists( serverMemoChildren, attributes.args.parent.get_id() & "-" & childWireInstanceIndex ) ) {
            var element = serverMemoChildren[ attributes.args.parent.get_id() & "-" & childWireInstanceIndex ];
            return "<#element.tag# wire:id=""#element.id#""></#element.tag#>";
        }
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
   
    structAppend( variables, attributes.cbwireComponent._getComputedPropertiesWithCaching() );

    structAppend( variables, attributes.args );

    //structAppend( variables, attributes.args.computed );

    include "#attributes.cbwireTemplate#";
</cfscript>