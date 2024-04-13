<cfscript>
    variables[ "getInstance" ] = function() {
        return attributes.cbwireComponent.getInstance( argumentCollection=arguments);
    }

    variables[ "data" ] = attributes.cbwireComponent.getDataProperties();

    variables[ "rc" ] = attributes.event.getCollection();

    variables[ "prc" ] = attributes.event.getPrivateCollection();

    variables[ "event" ] = attributes.event;

    variables[ "renderView" ] = function() {
        return attributes.event.getController().getRenderer().view( argumentCollection=arguments );
    };

    variables[ "view" ] = function() {
        return attributes.event.getController().getRenderer().view( argumentCollection=arguments );
    };

    attributes.cbwirecomponent.getParent().getMetaInfo().functions.each( function( cbwireFunction ) {
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