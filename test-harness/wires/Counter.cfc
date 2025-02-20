component extends="cbwire.models.Component" {
    data = {
        "counter": 0
    };

    function increment() {
        data.counter++;
    }

    function placeholder() {
        return "<div>some placeholder</div>";
    }

}