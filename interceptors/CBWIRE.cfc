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
        local.tmpDirectory = local.settings.moduleRootPath & "/models/tmp";

        if ( directoryExists( local.tmpDirectory ) ) {
            directoryDelete( local.tmpDirectory, true );
            directoryCreate( local.tmpDirectory );
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

    function preRender( event, data ) eventPattern="^cbwire.*" {
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
            arguments.data.renderedLayout = replaceNoCase( arguments.data.renderedLayout, "</head>", getStyles() & chr( 10 ) & "</head>", "one" );
            arguments.data.renderedLayout = replaceNoCase( arguments.data.renderedLayout, "</body>", getScripts() & chr( 10 ) & "</body>", "one" );
            request._cbwire_injected_assets = true;
        }
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
}