component extends="cbwire.models.Component" {

    data = {
        "message"= ""
    };

    function sayHello( required firstname, required lastname ){
        data.message = "Well hello " & arguments.firstname & " " & arguments.lastname;
    }

    function onRender(){
        return renderView( "wires/passActionArgs" );
    }

}
