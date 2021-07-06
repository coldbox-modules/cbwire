component extends="cbwire.models.Component" {

    variables.$data.message = "";

    variables.$listeners = { "someEvent" : "someListener" };

    function someAction(){
        this.$emit( "someEvent" );
    }

    function someListener(){
        variables.$data.message = "We have fired someListener() using this.$emit in our component!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/fireEvent" );
    }

}
