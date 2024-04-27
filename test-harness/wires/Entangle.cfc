component extends="cbwire.models.v4.Component" {

    data = {
        "counter": 0,
        "name": "Grant"
    };

    function increment() {
        data.counter += 1;
    }
}