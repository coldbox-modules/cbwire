component extends="cbwire.models.v4.Component" {
    
    function getTick() computed {
        sleep( 1000 );
        return getTickCount();
    }
}