<cfscript>

    function fileIsOutdated(sourcePath, cachePath) {
        return true;
        return getFileInfo(sourcePath).lastModified > getFileInfo(cachePath).lastModified;
    }

    function preprocessAndCacheFile(sourcePath, cachePath) {
        var content = fileRead( expandPath( sourcePath) );
        var processedContent = preprocessFile(content);
        fileWrite(cachePath, processedContent);
    }

    function preprocessFile(content) {
        // Grab all preprocessor classes and loop over them.
        local.preprocessors = variables.CBWIREComponent.getCBWIREController().getPreprocessors();
        // Loop over each, passing in the content we want to preprocess.
        local.preprocessors.each(function(preprocessor) {
            content = preprocessor.handle(content);
        });
        // Return the processed content.
        return content;
    }

    variables.CBWIREComponent = attributes.CBWIREComponent;
    variables.fullNormalizedPath = expandPath( attributes.normalizedPath );

    /*
        Continue with existing code logic...
    */
    variables.configSettings = variables.CBWIREComponent.getCBWIREController().getConfigSettings();

    if (structKeyExists(variables.configSettings, "applicationHelper") && isArray(variables.configSettings.applicationHelper)) {
        variables.configSettings.applicationHelper.each(function(includePath) {
            if (left(includePath, 1) != "/") {
                arguments.includePath = "/" & arguments.includePath;
            }
            include "#arguments.includePath#";
        });
    }

    /*
        Provide CBWIRE methods from the component to the view.
    */
    function addPublicMethods(_metaData) {
        arrayEach(_metaData.functions, function(cbwireFunction) {
            if (cbwireFunction.keyExists("computed")) {
                return;
            }
            variables[cbwireFunction.name] = function() {
                return invoke(attributes.CBWIREComponent, cbwireFunction.name, arguments );
            };
        });
        if (_metaData.keyExists("extends")) {
            addPublicMethods(_metaData.extends);
        }
    }

    addPublicMethods(attributes.CBWIREComponent._getMetaData());

    /*
        Provide computed property methods to the view.
    */
    function addComputedProperties(_metaData) {
        arrayEach(_metaData.functions, function(cbwireFunction) {
            if (!cbwireFunction.keyExists("computed")) {
                return;
            }
            variables[cbwireFunction.name] = function(cacheMethod = true) {
                return invoke(attributes.CBWIREComponent, cbwireFunction.name, arguments );
            };
        });
        if (_metaData.keyExists("extends")) {
            addComputedProperties(_metaData.extends);
        }
    }

    addComputedProperties(attributes.CBWIREComponent._getMetaData());

    /*
        Auto-validate and provide validation methods to view.
    */
    attributes.CBWIREComponent.validate();
    variables["validation"] = attributes.CBWIREComponent._getValidationResult();

    /* 
        Provide data properties to view.
    */
    variables.args = {};
    variables.data = {};
    variables.CBWIREComponent._getDataProperties().each(function(key, value) {
        variables[key] = value;
        variables.data[key] = value;
        variables.args[key] = value;
    });

    /*
        Provide params to view.
        Make sure to run this last so we always overwrite data properties with params.
    */
    attributes.params.each(function(key, value) {
        variables[key] = value;
    });

    structDelete(variables, "configSettings");

    variables.relativeCachePath = "tmp/" & hash(attributes.normalizedPath) & ".cfm";
    variables.cachePath = getCurrentTemplatePath().replaceNoCase( "RendererEncapsulator.cfm", "" ) & variables.relativeCachePath;

    /*
        Check if cached file exists and is up-to-date, if not, preprocess and cache.
    */
    if (!fileExists(variables.cachePath) || fileIsOutdated(variables.fullNormalizedPath, variables.cachePath)) {
        preprocessAndCacheFile(attributes.normalizedPath, variables.cachePath);
    }

    /*
        Include the processed and cached file.
    */
    include variables.relativeCachePath;

</cfscript>
