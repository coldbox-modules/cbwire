component extends="cbwire.models.v4.Component" accessors="true" {

    property name="count" default="1";

    function countPlusTen() computed {
        return getCount() + 10;
    }

    function tick() computed {
        return getTickCount();
    }

    function onMount( params ) {
        setCount( 10 );
    }

    /**
     * Increments the counter by 1.
     */
    public function increment() {
        setCount(getCount() + 1);
    }

    /**
     * Decrements the counter by 1.
     */
    public function decrement() {
        setCount(getCount() - 1);
    }

    /**
     * Decrements the counter by 1.
     */
    public function decrementWithDataDot(){
        data.count -= 1;
    }

    /**
     * Renders the component's HTML output with Livewire-compatible attributes.
     * @return The HTML representation of the component, including Livewire data attributes.
     */
    public string function renderIt() {
        return view("wires.Counter");
    }

}
