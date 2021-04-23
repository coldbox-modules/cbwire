component extends="cbLivewire.models.Component" accessors="true" {

    property name="name" default="Marty";

    function renderIt() {
        return renderView( "_cblivewire/usingSet" );
    }
}