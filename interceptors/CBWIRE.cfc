component {

    /**
     * Returns the module settings.
     * 
     * @return struct
     */
    function getSettings() {
        return getInstance( "coldbox:modulesettings:cbwire" );
    }

    /**
     * Returns the CBWIRE controller.
     * 
     * @return CBWIREController
     */
    function getCBWIREController() {
        return getInstance( "CBWIREController@cbwire" );
    }

    /** 
     * Performs module cleanup on fwreinit. 
     * 
     * @return void
     */
    function preReinit() {
        local.settings = getSettings();
        
        // Clean up single-file component temp directory
        local.tmpDirectory = local.settings.storagePath;
        if ( directoryExists( local.tmpDirectory ) ) {
            directoryDelete( local.tmpDirectory, true );
            directoryCreate( local.tmpDirectory );
        }
        
        // Clean up file uploads temp directory
        local.uploadsTmpDirectory = local.settings.uploadsStoragePath;
        if ( directoryExists( local.uploadsTmpDirectory ) ) {
            directoryDelete( local.uploadsTmpDirectory, true );
            directoryCreate( local.uploadsTmpDirectory );
        }
    }

    /**
     * Ensures that no other custom interceptors run for the cbwire module.
     * Returns true to break the interceptor chain.
     * 
     * @return boolean
     */
    function onException() {
        local.exception = arguments.interceptData.exception;
        if ( local.exception.type contains "CBWIRE:" ) {
            writeDump( var=buffer, top=2 );
            abort;
            return true;
        }
    }

    function onRequestCapture() eventPattern="^cbwire.*" {
        return true;
    }

    function onInvalidEvent() eventPattern="^cbwire.*" {
        return true;
    }

    function applicationEnd() eventPattern="^cbwire.*" {
        return true;
    }

    function sessionStart() eventPattern="^cbwire.*" {
        return true;
    }

    function sessionEnd() eventPattern="^cbwire.*" {
        return true;
    }

    function preProcess( event ) eventPattern="^cbwire.*" {
        if ( isUploadRequest( arguments.event ) ) return true;

        if ( missingLivewireHeader( arguments.event ) ) {
            arguments.event.renderData(
                type = "HTML",
                data = "",
                statusCode = 400
            ).noExecution();
        }
        return true;
    }

    function preEvent() eventPattern="^cbwire.*" {
        return true;
    }

    function postEvent() eventPattern="^cbwire.*" {
        return true;
    }

    function postProcess() eventPattern="^cbwire.*" {
        return true;
    }

    function preProxyResults() eventPattern="^cbwire.*" {
        return true;
    }

    function afterHandlerCreation() eventPattern="^cbwire.*" {
        return true;
    }

    function afterInstanceCreation() eventPattern="^cbwire.*" {
        return true;
    }

    function preLayout() eventPattern="^cbwire.*" {
        return true;
    }

    function preRender( event, data, interceptData ) {
        handleRequestAssets( argumentCollection=arguments );
        return true;
    }

    function postRender() eventPattern="^cbwire.*" {
        return true;
    }

    function preViewRender() eventPattern="^cbwire.*" {
        return true;
    }

    function postViewRender() eventPattern="^cbwire.*" {
        return true;
    }

    function preLayoutRender() eventPattern="^cbwire.*" {
        return true;
    }

    function postLayoutRender() {
        if ( shouldInject( arguments.event ) && !request.keyExists( "_cbwire_injected_assets" ) ) {
            // Get the layout file content to check for required tags
            local.layoutContent = getLayoutContent( arguments.event );
            
            // Check if the layout has required tags for asset injection
            if ( !findNoCase( "</head>", local.layoutContent ) ) {
                throw(
                    type = "CBWIREException",
                    message = "Layout is missing </head> tag required for wireStyles() injection.",
                    detail = "Your layout must include a </head> tag where CBWIRE can inject CSS styles. Either add a </head> tag to your layout or set 'autoInjectAssets' to false and manually call wireStyles() and wireScripts()."
                );
            }
            if ( !findNoCase( "</body>", local.layoutContent ) ) {
                throw(
                    type = "CBWIREException",
                    message = "Layout is missing </body> tag required for wireScripts() injection.",
                    detail = "Your layout must include a </body> tag where CBWIRE can inject JavaScript. Either add a </body> tag to your layout or set 'autoInjectAssets' to false and manually call wireStyles() and wireScripts()."
                );
            }

            arguments.data.renderedLayout = replaceNoCase( arguments.data.renderedLayout, "</head>", getStyles() & chr( 10 ) & "</head>", "one" );
            arguments.data.renderedLayout = replaceNoCase( arguments.data.renderedLayout, "</body>", getScripts() & chr( 10 ) & "</body>", "one" );
            request._cbwire_injected_assets = true;
        }
    }

    /**
     * Gets the layout file content for validation.
     * Reads the actual layout file from disk based on the current layout name.
     * 
     * @event The request context object
     * 
     * @return string The layout file content
     */
    private function getLayoutContent( event ) {
        // Get the current layout name from the private collection
        local.layoutName = arguments.event.getPrivateValue( "currentLayout", "" );
        
        if ( !len( local.layoutName ) ) {
            return "";
        }
        
        // Get the layouts directory path
        local.layoutsPath = expandPath( "/layouts/" );
        
        // Try common file extensions
        local.extensions = [ ".cfm", ".bxm" ];
        
        for ( local.ext in local.extensions ) {
            local.layoutFile = local.layoutsPath & local.layoutName & local.ext;
            if ( fileExists( local.layoutFile ) ) {
                return fileRead( local.layoutFile );
            }
        }
        
        // If we can't find the layout file, return empty string
        // This will allow the existing rendered content check to fail gracefully
        return "";
    }

    function preModuleLoad() eventPattern="^cbwire.*" {
        return true;
    }

    function postModuleLoad() eventPattern="^cbwire.*" {
        return true;
    }

    function preModuleUnload() eventPattern="^cbwire.*" {
        return true;
    }

    
    function postModuleUnload() eventPattern="^cbwire.*" {
        return true;
    }

    /**
     * Checks if the Livewire header is missing in the incoming request.
     * @event The incoming request event.
     * 
     * @return boolean
     */
    private function missingLivewireHeader( event ) {
        return event.getHTTPHeader( header="X-Livewire", defaultValue="false" ) == "false";
    }

    /**
     * Checks if the incoming request is an upload request.
     * @event The incoming request event.
     * 
     * @return boolean
     */
    private function isUploadRequest( event ) {
        return arrayFindNoCase( [ "cbwire:Main.uploadFile", "cbwire:Main.previewFile"], event.getCurrentEvent() );
    }

    /** 
     * Gets the styles to inject into the page.
     * 
     * @return string
     */
    private function getStyles() {
        return getCBWIREController().getStyles();
    }

    /** 
     * Gets the scripts to inject into the page.
     * 
     * @return string
     */
    private function getScripts() {
        return getCBWIREController().getScripts();
    }

    /**
     * Determines if the assets should be injected into the page.
     * 
     * @event The incoming request event.
     * 
     * @return boolean
     */
    private function shouldInject( event ) {
        local.settings = getSettings();
        return arguments.event.getCurrentModule() != "cbwire" && local.settings.autoInjectAssets == true;
    }

    /**
     * Handle append the assets from any components during the request 
     * by appending them to the head of the layout.
     *
     * @event | Event
     * @data | Struct
     * @interceptData | Struct
     * 
     * @return void
     */
    private function handleRequestAssets( event, data, interceptData ) {
        local.requestAssets = arguments.event.getPrivateValue( "cbwireRequestAssets", {} );
        local.requestAssets.each( function( key, value ) {
            interceptData.renderedContent = interceptData.renderedContent.replaceNoCase( "</head>", value & chr( 10 ) & "</head>", "one" );
        } );
    }
}