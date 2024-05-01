component extends="cbwire.models.Component" {
    
    function getTick() computed {
        sleep( 1000 );
        return getTickCount();
    }
}