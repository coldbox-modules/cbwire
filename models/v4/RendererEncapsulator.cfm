<!--- 
/* 
            Create reference to local scope for the method.
        */
        local.localScope = local;
        /* 
            Take our data properties and make them available as variables
            to the view.
        */
        variables.data.each( function( key, value ) {
            local.localScope[ key ] = value;
        } );

        /* 
            Take any params passed to the view method and make them available as variables
            within the view template. This allows for dynamic content to be rendered based on
            the parameters passed to the view method.
        */
        params.each( function( key, value ) {
            local.localScope[ key ] = value;
        } );

        // Provide 'args' scope to the view
        local.localScope.args = localScope;

        savecontent variable="local.localScope.viewContent" {
            // The leading slash in the include path might need to be removed depending on your server setup
            // or application structure, as cfinclude paths are relative to the application root.
            include "#arguments.normalizedPath#"; // Dynamically includes the CFML file for processing.
        }
        return local.localScope.viewContent;

--->

<cfscript>
    
    variables.CBWIREComponent = attributes.CBWIREComponent;

    /*
        Provide applicationHelper methods to view.
    */
    variables.configSettings = variables.CBWIREComponent.getCBWIREController().getConfigSettings();

    if ( structKeyExists( variables.configSettings, "applicationHelper" ) && isArray( variables.configSettings.applicationHelper ) ) {
        variables.configSettings.applicationHelper.each( function( includePath ) {
            if ( left( includePath, 1 ) != "/" ) {
                arguments.includePath = "/" & arguments.includePath;
            }
            include "#arguments.includePath#";
        } );
    }

    /*
        Provide CBWIRE methods from the component to the view.
    */
    variables.CBWIREViewMethods = [ "getInstance", "wire" ];
    arrayEach( variables.CBWIREViewMethods, function( methodName ) {
        variables[ methodName ] = function() {
            return invoke( attributes.CBWIREComponent, methodName, arguments );
        };
    } );

    structDelete( variables, "CBWIREViewMethods" );

    /*
        Provide computed properties to view.
    */
    arrayEach( attributes.CBWIREComponent._getMetaData().functions, function( cbwireFunction ) {
        if ( !cbwireFunction.keyExists( "computed" ) ) {
            return;
        }
        variables[ cbwireFunction.name ] = function( cacheMethod = true ) {
            return invoke( attributes.CBWIREComponent, cbwireFunction.name, { cacheMethod2 = cacheMethod } );
        };
    } );

    /*
        Auto-validate and provide validation methods to view.
    */
    attributes.CBWIREComponent.validate();
    variables[ "validation" ] = attributes.CBWIREComponent._getValidationResult();

    /* 
        Provide data properties to view.
    */
    variables.args = {};
    variables.CBWIREComponent._getDataProperties().each( function( key, value ) {
        variables[ key ] = value;
        variables.args[ key ] = value;
    } );

    /*
        Provide params to view.
        Make sure to run this last so we always overwrite 
        data properties with params.
    */
    attributes.params.each( function( key, value ) {
        variables[ key ] = value;
    } );
   
    structDelete( variables, "configSettings" );

    include "#attributes.normalizedPath#";
</cfscript>