component extends="cbwire.models.v4.Component" {

    data = {
        "submitted": false
    };

    function submit() {
        js( "alert('Hello from CBWIRE!')" );
        js( "console.log( 'Output to console from CBWIRE!')" );
        js( "$wire.submitted = true" );
    }
}