component extends="cbwire.models.Component" {


    this.template = "wires/entangle";

    data = {
        "counter": 0,
        "name": "Grant"
    };

    function increment() {
        data.counter += 1;
    }
}