component extends="cbwire.models.Component" {

    variables.data = {
        "message": ""
    };

    function calledMethod(){
        variables.data[ "message" ] = "We have called our method!";
    }

    function renderIt(){
        return this.renderView( "_wires/callMethod" );
    }

}
