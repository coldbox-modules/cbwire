component extends="cbwire.models.Component" {

    variables.data = { "message" : "" };

    function saySomething(){
        variables.data.message = "Something ( again )!";
    }

    function renderIt(){
        return this.$renderView( "_wires/nestedComponent2" );
    }

}
