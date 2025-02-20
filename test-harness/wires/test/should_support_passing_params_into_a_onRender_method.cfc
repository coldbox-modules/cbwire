component extends="cbwire.models.Component" {

    data = {
        title: "I rendered from onRender"
    };

    function onRender() {
        return template( "wires.test.should_support_passing_params_into_a_onRender_method", { "value": 5 } );
    }
}
