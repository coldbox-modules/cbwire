component
    extends="cbwire.models.Component"
    accessors="true"
{

    property
        name="message"
        default="";

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
