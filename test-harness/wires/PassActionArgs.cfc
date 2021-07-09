component extends="cbwire.models.Component" {

    variables.data[ "message" ] = "";

    function sayHello(
        required firstname,
        required lastname
    ){
        this.setMessage( "Well hello " & arguments.firstname & " " & arguments.lastname );
    }

    function $renderIt(){
        return this.$renderView( "_wires/passActionArgs" );
    }

}
