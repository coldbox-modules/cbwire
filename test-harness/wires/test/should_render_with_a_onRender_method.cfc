component extends="cbwire.models.Component" {

    data = {
        title: "I rendered from onRender"
    };

    function onRender() {
        return "<div><p>#data.title#</p></div>";
    }
}
