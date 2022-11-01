component extends="cbwire.models.Component" {

    data = {
        "message": "Default value"
    };

    function onMount(){
        data.message = "Mounted value";
    }

    function renderIt(){
        return this.renderView( "wires/mount" );
    }

}
