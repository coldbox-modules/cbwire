component extends="cbwire.models.Component" {

    this.$data = {
        "message": ""
    };

    function saySomething(){
        this.$data.message = "Something ( again )!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/nestedComponent2" );
    }

}
