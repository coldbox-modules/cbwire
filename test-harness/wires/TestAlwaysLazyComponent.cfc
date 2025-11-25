component extends="cbwire.models.Component" {

    lazy = true;

    data = {
        "title": "Always Lazy Component"
    };

    function placeholder() {
        return "<div>Always Lazy Placeholder</div>";
    }

}