component extends="cbLivewire.models.Component" accessors="true" {

    property name="name" default="Marty";

    function resetName( otherName ) {
        setName( otherName );
    }

    function renderIt() {
        return renderView( "_cblivewire/passMethodArgs" );
    }
}