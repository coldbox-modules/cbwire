component extends="cbLivewire.models.Component" accessors="true" {

    function $renderIt(){
        return this.$renderView( "_cbLivewire/emitFromButton" );
    }
}