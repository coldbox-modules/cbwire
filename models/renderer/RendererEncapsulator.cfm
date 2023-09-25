<cfscript>
    configSettings = attributes.cbwireComponent.getInstance( dsl="coldbox:configSettings" );

    if ( structKeyExists( configSettings, "applicationHelper" ) && isArray( configSettings.applicationHelper ) ) {
        configSettings.applicationHelper.each( function( includePath ) {
            include template=includePath;
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

    variables[ "wire" ] = function( componentName, parameters = {} ) {
        var lineNumber = callStackGet()[ 2 ].lineNumber;
        var comp = application.wirebox.getInstance( "CBWireService@cbwire" )
                   .getComponentInstance( arguments.componentName )
                   .startup();

        comp.setID( attributes.args.parent.getID() & "-" & lineNumber );

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