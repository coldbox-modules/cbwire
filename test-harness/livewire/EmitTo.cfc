component extends="cbLivewire.models.Component"{

    function someAction(){
        this.$emitTo( "livewire.FireEvent2", "someEvent" );
    }

    function $renderIt(){
        return this.$renderView( "_cblivewire/emitTo" );
    }
}