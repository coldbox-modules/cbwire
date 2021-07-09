component extends="cbwire.models.Component" {

    function mount(){
        variables.data.message = "default";
    }

    function calledMethod(){
        variables.data.message = "We have called our method!";
    }

    function renderIt(){
        return this.renderView( "_wires/callMethod" );
    }

}
