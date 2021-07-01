component extends="cbwire.models.Component" {

    property
        name="message"
        default="";

    this.$listeners = { "someEvent" : "someListener" };

    function mount(){
        this.$emit( "someEvent" );
    }

    function someListener(){
        variables.message = "We have fired someListener() using this.$emit in our component!";
    }

    function $renderIt(){
        return this.$renderView( "_cbwire/fireEvent" );
    }

}
