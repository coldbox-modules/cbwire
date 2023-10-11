<cfscript>
    configSettings = attributes.cbwireComponent.getInstance( dsl="coldbox:configSettings" );

    if ( structKeyExists( configSettings, "applicationHelper" ) && isArray( configSettings.applicationHelper ) ) {
        configSettings.applicationHelper.each( function( includePath ) {
            if ( left( includePath, 1 ) != "/" ) {
                arguments.includePath = "/" & arguments.includePath;
            }
            include "#arguments.includePath#";
        } );
    }

    variables[ "getInstance" ] = attributes.cbwireComponent.getInstance;

    variables[ "data" ] = attributes.cbwireComponent.getDataProperties();

    variables[ "rc" ] = attributes.event.getCollection();

    variables[ "prc" ] = attributes.event.getPrivateCollection();

    getMetaData( attributes.cbwirecomponent.getParent() ).functions.each( function( cbwireFunction ) {
        variables[ cbwireFunction.name ] = function() {
            return invoke( attributes.cbwireComponent.getParent(), cbwireFunction.name, arguments );
        };
    } );

    variables[ "wire" ] = function( componentName, parameters = {}, key = "" ) {
        var lineNumber = callStackGet()[ 2 ].lineNumber;
        var comp = application.wirebox.getInstance( "CBWireService@cbwire" )
                   .getComponentInstance( arguments.componentName )
                   .startup();

        var componentIdentifier = attributes.args.parent.getID() & "-" & lineNumber;
        if ( toString( arguments.key ).len() ) {
            componentIdentifier &= "-" & toString( arguments.key );
        }
        comp.setID( componentIdentifier );
        if ( !attributes.cbwireComponent.getIsInitialRendering() && attributes.cbwireComponent.hasServerMemo() ) {
            var serverMemo = attributes.cbwireComponent.getServerMemo();
            if ( structKeyExists( serverMemo.children, comp.getID() ) ) {
                var tag = serverMemo.children[ comp.getID() ].tag;
                // We need to partially render this component as it's
                // already been rendered by the browser.
                return "<#tag# wire:id=""#componentIdentifier#""></#tag#>";
            }
        }

        return comp.mount( arguments.parameters )
                   .renderIt();
    };

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