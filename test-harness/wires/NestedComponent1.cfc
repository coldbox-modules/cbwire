component extends="cbwire.models.Component" {

    data = { "message" : "" };

    function saySomething(){
        data.message = "Something";
    }

    function renderIt(){
        return this.renderView( "_wires/nestedComponent1" );
    }

}
