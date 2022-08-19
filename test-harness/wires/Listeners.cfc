component extends="cbwire.models.Component" {

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