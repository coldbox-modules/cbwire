component extends="cbwire.models.Component" {

    data = {
        "submitted": false
    };

    function submit() {
        js( "alert('Hello from CBWIRE!')" );
        js( "console.log( 'Output to console from CBWIRE!')" );
        js( "$wire.submitted = true" );
    }
}