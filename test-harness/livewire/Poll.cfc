component extends="cbLivewire.models.Component" {

    property
        name="timestamp"
        default="#now()#";

    function getTimestamp(){
        return now() & "what!";
    }

    function $renderIt(){
        return this.$renderView( "_cblivewire/poll" );
    }

}
