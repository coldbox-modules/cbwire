component extends="cbwire.models.Component" {

    data = {
        "message": "Default value"
    };

    function mount(){
        data.message = "Mounted value";
    }

    function renderIt(){
        return this.renderView( "wires/mount" );
    }

}
