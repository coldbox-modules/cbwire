component extends="cbwire.models.Component" {

    property
        name="message"
        default="";

    this.$listeners = { "someEvent" : "someListener" };

    function someAction(){
        this.$emit( "someEvent" );
    }

    function someListener(){
        variables.message = "We have fired someListener() from a second listener!";
    }

    function $renderIt(){
        return this.$renderView( "_cbwire/fireEvent" );
    }

}
