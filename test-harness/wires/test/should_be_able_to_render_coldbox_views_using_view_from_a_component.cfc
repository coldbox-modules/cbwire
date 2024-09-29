component extends="cbwire.models.Component" {

    function onRender() {
        return view( "testView", { input: "Rendered from component!" } );
    }
}