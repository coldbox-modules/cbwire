component extends="cbwire.models.Component" {
    data = {
        "counter": 0
    };

    function increment() {
        data.counter++;
    }

    function decrement() {
        data.counter--;
    }

    function isEven() {
        return data.counter % 2 == 0;
    }

    function incrementBy( amount ) {
        data.counter += amount;
    }

    function onRender() {
        return template( "wires.CounterComplete", { isEven: isEven() } );
    }
}