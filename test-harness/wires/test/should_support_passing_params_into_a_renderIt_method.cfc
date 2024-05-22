component extends="cbwire.models.Component" {

    data = {
        title: "I rendered from renderIt"
    };

    function renderIt() {
        return view( "wires.test.should_support_passing_params_into_a_renderIt_method", { "value": 5 } );
    }
}
