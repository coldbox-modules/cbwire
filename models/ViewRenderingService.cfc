component accessors="true" singleton {


    property name="cbwireController" inject="CBWIREController@cbwire";
    property name="utilityService" inject="UtilityService@cbwire";

    /**
     * Normalizes the view path for rendering. This means it will convert the dot notation path 
     * to a slash notation path, check for the existence of .bxm or .cfm files, and ensure the path is correctly formatted.
     *
     * @viewPath string | The dot notation path to the view template to be rendered, without the .cfm extension.
     *
     * @return string
     */
    function normalizeViewPath( required viewPath ) {
        // Replace all dots with slashes to normalize the path
        local.normalizedPath = replace( arguments.viewPath, ".", "/", "all" );
        local.fullNormalizedPath = expandPath( "/" & local.normalizedPath );
        local.bxmViewFullPath = local.fullNormalizedPath & ".bxm";
        local.cfmViewFullPath = local.fullNormalizedPath & ".cfm";

        if ( local.normalizedPath contains "cbwire/models/tmp/" ) {
            if ( utilityService.fileExists( bxmViewFullPath ) ) {
                return "/" & local.normalizedPath & ".bxm";
            } else {
                return "/" & local.normalizedPath & ".cfm";
            }
        }

        if ( utilityService.fileExists( bxmViewFullPath ) ) {
            local.normalizedPath &= ".bxm";
        } else if ( utilityService.fileExists( cfmViewFullPath ) ) {
            local.normalizedPath &= ".cfm";
        } else {
            throw( type="CBWIREException", message="A .bxm or .cfm template could not be found for '#arguments.viewPath#'." );
        }

        // Ensure the path starts with "/wires/" without duplicating it
        if ( left(local.normalizedPath, 6) != "wires/" ) {
            local.normalizedPath = "wires/" & local.normalizedPath;
        }
        // Prepend a leading slash if not present
        if (left(local.normalizedPath, 1) != "/") {
            local.normalizedPath = "/" & local.normalizedPath;
        }

        return local.normalizedPath;

    }

    function getTemplatePath( required wire, required path ) {
        if ( isModulePath( arguments.path ) ) {
            var moduleRoot = cbwireController.getModuleRootPath( wire._getModuleName() );
            return moduleRoot & ".wires." & wire._getComponentName().listFirst( "@" );
        }

        return "wires." & arguments.path;
    }

    /**
     * Returns true if the path contains a module.
     *
     * @return boolean
     */
    function isModulePath( required viewPath ) {
        return arguments.viewPath contains "@";
    }

    /**
     * Captures the return values from the RendererEncapsulator like cbwire:script and cbwire:assets tags.
     *
     * @return void
     */
    function captureTemplateReturnValues( required wire, required returnValues ) {
        // Parse and track cbwire:script tags
        arguments.returnValues.filter( function( key, value ) {
            return key.findNoCase( "script" );
        } ).each( function( key, value, result ) {
            // Extract the counter from the tag name
            local.counter = key.replaceNoCase( "script", "" );
            // Create script tag id based on compile time id and counter
            local.scriptTagId = wire._getCompileTimeKey() & "-" & local.counter;
            // Track the script tag
            wire._trackScript( local.scriptTagId, value );
        } );

        // Parse and track cbwire:assets tags
        arguments.returnValues.filter( function( key, value ) {
            return key.findNoCase( "assets" );
        } ).each( function( key, value, result ) {
            // Extract the counter from the tag name
            local.counter = key.replaceNoCase( "assets", "" );
            // Create assets tag id based on hash of assets
            local.assetsTagId = hash( value, "MD5" );
            // Track the assets tag
            wire._trackAsset( local.assetsTagId, value );
            local.requestAssets = cbwireController.getRequestAssets();
            local.requestAssets[ local.assetsTagId ] = value;
        } );
    }
}