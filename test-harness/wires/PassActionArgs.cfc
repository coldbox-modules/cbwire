component extends="cbwire.models.Component" {

    data[ "message" ] = "";

    function sayHello(
        required firstname,
        required lastname
    ){
        this.setMessage( "Well hello " & arguments.firstname & " " & arguments.lastname );
    }

    function renderIt(){
        return this.renderView( "wires/passActionArgs" );
    }

}
