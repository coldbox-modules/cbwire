<cfscript>
	httpRequestData = getHTTPRequestData();

    childWireInstanceIndex = 0;

    serverMemoChildren = httpRequestData.content.len() ? deserializeJson( httpRequestData.content ).serverMemo.children : {};

    isSingleFileComponent = attributes.cbwirecomponent.getParent().isSingleFileComponent();

    variables[ "getInstance" ] = attributes.cbwireComponent.getInstance;

    variables[ "data" ] = attributes.cbwireComponent.getDataProperties();

    variables[ "rc" ] = attributes.event.getCollection();

    variables[ "prc" ] = attributes.event.getPrivateCollection();

    functions = getMetaData( attributes.cbwirecomponent.getParent() ).functions;
    functions.each( function( cbwireFunction ) {
        variables[ cbwireFunction.name ] = function() {
            return invoke( attributes.cbwireComponent.getParent(), cbwireFunction.name, arguments );
        };
    } );

    variables.wire = function( componentName, parameters = {} ) {
        var lineNumber = callStackGet()[ 2 ].lineNumber;
        
        // if ( structKeyExists( serverMemoChildren, attributes.args.parent.getID() & "-" & lineNumber ) ) {
        //     var element = serverMemoChildren[ attributes.args.parent.getID() & "-" & lineNumber ];
        //     return "<#element.tag# wire:id=""#element.id#""></#element.tag#>";
        // }

        var comp = application.wirebox.getInstance( "CBWireService@cbwire" )
                   .getComponentInstance( arguments.componentName )
                   .startup();

        comp.setID( attributes.args.parent.getID() & "-" & lineNumber );

        return comp.mount( arguments.parameters )
                   .renderIt();
    };

    variables.entangle = function( required prop ) {
        var cbwireService = application.wirebox.getInstance( "CBWireService@cbwire" );
        return cbwireService.entangle( argumentCollection=arguments );
    };
    variables.args = attributes.args;
   
    structAppend( variables, attributes.cbwireComponent.getComputedPropertiesWithCaching() );

    structAppend( variables, attributes.args );

    //structAppend( variables, attributes.args.computed );

    include "#attributes.cbwireTemplate#";
</cfscript>