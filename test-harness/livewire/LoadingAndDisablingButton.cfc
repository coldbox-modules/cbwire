component extends="cbLivewire.models.Component"{

    function checkout(){
        sleep( 5000 );
    }

    function $renderIt(){
        return this.$renderView( "_cblivewire/loadingAndDisablingButton" );
    }
}