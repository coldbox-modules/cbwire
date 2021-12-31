component extends="cbwire.models.Component" {

    variables.view = "_wires/flash";

    // Action
    function doSomething(){
        flash.put( "notice", "Some notice!" );
    }

    function doNothing() {}
}