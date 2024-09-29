component extends="cbwire.models.Component"{

    function onMount(){
        log.debug( "Loaded mount()" );
    }

    function onRender(){
        return renderView( "wires/logbox" );
    }

}