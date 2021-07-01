component
    extends="cbLivewire.models.Component"
    accessors="true"
{

    property
        name="message"
        default="We have data binding!";

    function $renderIt(){
        return this.$renderView( "_cblivewire/dataBinding" );
    }

}
