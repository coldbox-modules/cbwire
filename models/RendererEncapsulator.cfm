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
    function addPublicMethods( _metaData ) {
        arrayEach(_metaData.functions, function(cbwireFunction) {
            if (cbwireFunction.keyExists("computed")) {
                return;
            }
            variables[cbwireFunction.name] = function() {
                return invoke(attributes.CBWIREComponent, cbwireFunction.name, arguments );
            };
        });
        if (_metaData.keyExists( "extends" ) ) {
            addPublicMethods( _metaData.extends );
        }
    }
    
    addPublicMethods( attributes.CBWIREComponent._getMetaData() );

    /*
        Provide computed property methods to the view.
    */
    function addComputedProperties( _metaData ) {
        arrayEach(_metaData.functions, function(cbwireFunction) {
            if (!cbwireFunction.keyExists("computed")) {
                return;
            }
            variables[cbwireFunction.name] = function(cacheMethod = true) {
                return invoke(attributes.CBWIREComponent, cbwireFunction.name, arguments );
            };
        });
        if (_metaData.keyExists( "extends" ) ) {
            addComputedProperties( _metaData.extends );
        }
    }
     
    addComputedProperties( attributes.CBWIREComponent._getMetaData() );

    /*
        Auto-validate and provide validation methods to view.
    */
    attributes.CBWIREComponent.validate();
    variables[ "validation" ] = attributes.CBWIREComponent._getValidationResult();

    /* 
        Provide data properties to view.
    */
    variables.args = {};
    variables.data = {};
    variables.CBWIREComponent._getDataProperties().each( function( key, value ) {
        variables[ key ] = value;
        variables.data[ key ] = value;
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