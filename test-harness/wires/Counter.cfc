component extends="cbwire.models.Component" {
    data = {
        "counter": 0
    };

    computed = {
        "isEven": function() {
            return data.counter % 2 == 0 ? true : false;
        }
    }

    function increment() {
        data.counter += 1;
    }
}