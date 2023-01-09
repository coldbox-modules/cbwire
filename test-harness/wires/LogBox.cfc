component extends="cbwire.models.Component"{

    function onMount(){
        log.debug( "Loaded mount()" );
    }

    function renderIt(){
        return renderView( "wires/logbox" );
    }

}