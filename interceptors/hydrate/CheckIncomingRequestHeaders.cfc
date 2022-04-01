/**
 * Ensure the incoming cbwire request include an 'X-Livewire' heading with a 
 * value of 'true', otherwise reject the request.
 */
component {

    function preProcess( event ) eventPattern="cbwire.main.index"{
        if ( event.getHTTPHeader( header="X-Livewire", defaultValue="" ) != "true" ) {
            event.renderData(
                type = "HTML",
                data = "",
                statusCode = 400
            ).noExecution();
            // Returning true breaks further interceptors execution.
            return true;
        }
    }
}