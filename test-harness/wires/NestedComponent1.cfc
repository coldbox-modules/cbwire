component extends="cbwire.models.Component" {

    property
        name="message"
        default="";

    function saySomething(){
        variables.message = "Something";
    }

    function $renderIt(){
        return this.$renderView( "_cbwire/nestedComponent1" );
    }

}
