component extends="cbwire.models.v4.Component" {

    // Data properties
    data = {
        "message": "Is it lunch time yet?"
    };

    // Action
    function sendMessage() {
        // Emit event from CBWIRE
        emit( "success", [ now() ] );
    }
}