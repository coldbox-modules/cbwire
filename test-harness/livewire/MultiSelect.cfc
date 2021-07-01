component extends="cbLivewire.models.Component" {

    property
        name="greeting"
        default="";

    function $renderIt(){
        return this.$renderView( "_cblivewire/multiselect" );
    }

}
