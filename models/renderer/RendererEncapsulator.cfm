<cfscript>
    variables[ "getInstance" ] = function() {
        return attributes.cbwireComponent.getInstance( argumentCollection=arguments);
    }

    variables[ "data" ] = attributes.cbwireComponent.getDataProperties();

    variables[ "rc" ] = attributes.event.getCollection();

    variables[ "prc" ] = attributes.event.getPrivateCollection();

    variables[ "event" ] = attributes.event;

    variables[ "renderView" ] = function() {
        return attributes.event.getController().getRenderer().renderView( argumentCollection=arguments );
    };

    variables[ "view" ] = function() {
        return attributes.event.getController().getRenderer().renderView( argumentCollection=arguments );
    };

    getMetaData( attributes.cbwirecomponent.getParent() ).functions.each( function( cbwireFunction ) {
        variables[ cbwireFunction.name ] = function() {
            return invoke( attributes.cbwireComponent.getParent(), cbwireFunction.name, arguments );
        };
    } );

    configSettings = attributes.cbwireComponent.getInstance( dsl="coldbox:configSettings" );

    if ( structKeyExists( configSettings, "applicationHelper" ) && isArray( configSettings.applicationHelper ) ) {
        configSettings.applicationHelper.each( function( includePath ) {
            if ( left( includePath, 1 ) != "/" ) {
                arguments.includePath = "/" & arguments.includePath;
            }
            include "#arguments.includePath#";
        } );
    }



    // variables[ "wire" ] = function( componentName, parameters = {}, key = "" ) {
    //     var lineNumber = callStackGet()[ 2 ].lineNumber;
    //     var comp = application.wirebox.getInstance( "CBWireService@cbwire" )
    //                .getComponentInstance( arguments.componentName )
    //                .startup();

    //     var componentIdentifier = createUUID() & "-" & lineNumber;
    //     if ( toString( arguments.key ).len() ) {
    //         componentIdentifier = toString( arguments.key ) & "-" & lineNumber;
    //     }
    //     comp.setID( componentIdentifier );

    //     if ( attributes.cbwireComponent.getIsInitialRendering() ) {
    //         return comp.mount( arguments.parameters )
    //                    .renderIt();
    //     }

    //     var serverMemo = attributes.cbwireComponent.getServerMemo();
    //     if ( structKeyExists( serverMemo.children, comp.getID() ) ) {
    //         // This has already been rendered by the server.
    //         // Pass in the id and tag so we can partially render it.
    //         return comp.partiallyRenderIt( id=componentIdentifier, tag=serverMemo.children[ comp.getID() ].tag );
    //     } else {
    //         return comp.mount( arguments.parameters )
    //                    .renderIt();
    //     }
    // };

    variables[ "entangle" ] = function( required prop ) {
        var cbwireService = application.wirebox.getInstance( "CBWireService@cbwire" );
        return cbwireService.entangle( argumentCollection=arguments );
    };

    variables.args = attributes.args;
   
    structAppend( variables, attributes.cbwireComponent.getComputedPropertiesWithCaching() );

    structAppend( variables, attributes.args );

    structDelete( variables, "configSettings" );

    include "#attributes.cbwireTemplate#";
</cfscript>