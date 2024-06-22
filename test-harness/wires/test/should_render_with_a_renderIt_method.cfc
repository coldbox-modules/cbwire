component extends="cbwire.models.Component" {

    data = {
        title: "I rendered from renderIt"
    };

    function renderIt() {
        return "<div><p>#data.title#</p></div>";
    }
}
