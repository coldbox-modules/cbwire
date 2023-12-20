/**
 * Ensure the incoming cbwire request include an 'X-Livewire' heading with a 
 * value of 'true', otherwise reject the request.
 */
component {

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

    private function missingLivewireHeader( event ) {
        return event.getHTTPHeader( header="X-Livewire", defaultValue="" ) != "true";
    }

    private function isUploadRequest( event ) {
        return arrayFindNoCase( [ "cbwire:Main.uploadFile", "cbwire:Main.previewFile"], event.getCurrentEvent() );
    }
}