<cfscript>
	httpRequestData = getHTTPRequestData();

    childWireInstanceIndex = 0;

    serverMemoChildren = httpRequestData.content.len() ? deserializeJson( httpRequestData.content ).serverMemo.children : {};


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

    structAppend( variables, attributes.args );

    structAppend( variables, attributes.args.computed );

    include "#attributes.cbwireTemplate#";
</cfscript>