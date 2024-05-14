component extends="cbwire.models.Component" {
    data = {
        "counter": 0,
        "counters": []
    };

    function onMount() {
        data.counter = 5;
        data.counters = [1,2,3];
    }
    function increment() {
        data.counter++;
        if ( data.counter > 10 ) {
            js( "
                Swal.fire({
                    title: 'Good job!',
                    text: 'You clicked the button 10 times!',
                    icon: 'success'
                })
            ");
        }
        return data.counter;
    }

    function incrementBy( amount ) {
        data.counter += amount;
    }

    function startOver() {
        reset( [ "counter" ] );
    }

    function renderIt() {
        return view( "wires.Counter", {
            "isEven": ( data.counter % 2 == 0 )
        } );
    }
}