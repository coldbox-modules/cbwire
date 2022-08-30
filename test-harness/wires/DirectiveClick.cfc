component extends="cbwire.models.Component" {

    data = {
        "clicks": 0
    };

    function increment() {
        data.clicks += 1;
    }
}	