component extends="cbwire.models.Component" {

    this.$data.message = "";

    this.$listeners = { "someEvent" : "someListener" };

    function someAction(){
        this.$emit( "someEvent" );
    }

    function someListener(){
        this.$data.message = "We have fired someListener() using this.$emit in our component!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/fireEvent" );
    }

}
