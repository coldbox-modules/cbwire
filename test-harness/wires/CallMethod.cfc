component extends="cbwire.models.Component" {

    data = {
        "message": ""
    };

    function calledMethod(){
        data[ "message" ] = "We have called our method!";
    }

    function renderIt(){
        return this.renderView( "wires/callMethod" );
    }

}
