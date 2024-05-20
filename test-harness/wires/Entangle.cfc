component extends="cbwire.models.Component" {

    data = {
        "counter": 0,
        "name": "Grant"
    };

    function increment() {
        data.counter += 1;
    }
}