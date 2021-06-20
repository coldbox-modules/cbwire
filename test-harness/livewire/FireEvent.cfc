component extends="cbLivewire.models.Component"{

    property name="message" default="";

    function someAction(){
        this.$emit( "someOtherEvent" );
    }

    function $renderIt() {
        return this.$renderView( "_cblivewire/fireEvent" );
    }
}