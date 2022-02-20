component extends="cbwire.models.Component" {

    data = { "message" : "" };

    function saySomething(){
        data.message = "Something ( again )!";
    }

    function renderIt(){
        return this.renderView( "_wires/nestedComponent2" );
    }

}
