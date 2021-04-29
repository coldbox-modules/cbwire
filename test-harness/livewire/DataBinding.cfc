component extends="cbLivewire.models.Component" accessors="true" {

    property name="message" default="We have data binding!";

    function renderIt() {
        return renderView( "_cblivewire/dataBinding" );
    }
}