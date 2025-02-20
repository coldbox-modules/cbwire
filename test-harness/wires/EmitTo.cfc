component extends="cbwire.models.Component" {

    function someAction(){
        this.emitTo( "wires.FireEvent2", "someEvent" );
    }

    function onRender(){
        return this.renderView( "wires/emitTo" );
    }

}
