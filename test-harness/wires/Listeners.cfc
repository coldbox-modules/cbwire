component extends="cbwire.models.Component" {

    // Data properties
    data = {
        "message": "Is it lunch time yet?",
        "sent": false
    };

    // Listener Definitions
    listeners = {
        "sentMessage": "showSent"
    };

    // Listener method
    function showSent() {
        data.sent = true;
    }

    // Action
    function sendMessage() {
        // Emit event from CBWIRE
        emit( "sentMessage" );
    }
}