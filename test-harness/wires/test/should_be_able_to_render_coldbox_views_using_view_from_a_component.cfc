component extends="cbwire.models.Component" {

    function renderIt() {
        return view( "testView", { input: "Rendered from component!" } );
    }
}