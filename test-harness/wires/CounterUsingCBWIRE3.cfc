component extends="cbwire.models.v4.Component" accessors="true" {

    data = {
        "count": 1
    };

    computed = {
        "countPlusTen": function() {
            return data.count + 10;
        },
        "tick": function(){
            return getTickCount();
        }
    };

    function onMount( params ) {
        data.count = 10;
    }

    /**
     * Increments the counter by 1.
     */
    public function increment() {
        data.count += 1;
    }

    /**
     * Decrements the counter by 1.
     */
    public function decrement() {
        data.count -= 1;
    }


    /**
     * Renders the component's HTML output with Livewire-compatible attributes.
     * @return The HTML representation of the component, including Livewire data attributes.
     */
    public string function renderIt() {
        return view("wires.CounterUsingDataDot");
    }

}
