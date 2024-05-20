/**
 * Ensure the incoming cbwire request include an 'X-Livewire' heading with a 
 * value of 'true', otherwise reject the request.
 */
component {
    /**
     * Pre-processes the incoming request event.
     * @param event The incoming request event.
     * @return True if the further interceptors execution should be stopped, false otherwise.
     */
    function preProcess( event ) eventPattern="^cbwire.*"{
        if ( isUploadRequest( event ) ) return;

        if ( missingLivewireHeader( event ) ) {
            event.renderData(
                type = "HTML",
                data = "",
                statusCode = 400
            ).noExecution();
            // Returning true breaks further interceptors execution.
            return true;
        }
    }

    /**
     * Checks if the Livewire header is missing in the incoming request.
     * @param event The incoming request event.
     * @return True if the Livewire header is missing, false otherwise.
     */
    private function missingLivewireHeader( event ) {
        return event.getHTTPHeader( header="X-Livewire", defaultValue="false" ) == "false";
    }

    /**
     * Checks if the incoming request is an upload request.
     * @param event The incoming request event.
     * @return True if the request is an upload request, false otherwise.
     */
    private function isUploadRequest( event ) {
        return arrayFindNoCase( [ "cbwire:Main.uploadFile", "cbwire:Main.previewFile"], event.getCurrentEvent() );
    }
}