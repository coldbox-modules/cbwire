component extends="cbLivewire.models.Component" accessors="true" {

    property name="name" default="Marty";

    function render() {
        return renderView( "_cblivewire/usingSet" );
    }
}