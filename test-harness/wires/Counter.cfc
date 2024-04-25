component extends="cbwire.models.v4.Component" accessors="true" {

    property name="count" default="1";
    property name="submitted" default="false";

    function countPlusTen() computed {
        return getCount() + 10;
    }

    function tick() computed {
        return getTickCount();
    }

    /**
     * Increments the counter by 1.
     */
    function increment() {
        data.count += 1;
        dispatch( "incremented" );
    }

    /**
     * Increments the counter by a specified amount.
     */
    function incrementBy( amount ) {
        data.count += amount;
        dispatch( "incrementedBy", 10 );
    }

    /**
     * Increments and dispatches to another component.
     * 
     * @return void
     */
    function incrementDispatchTo() {
        data.count += 1;
        dispatchTo( "anotherComponent", "incremented" );
    }

    /**
     * Increments and dispatches self
     * @return void
     */
    function incrementDispatchSelf() {
        data.count += 1;
        dispatchSelf( "incremented" );
    }

    /**
     * Decrements the counter by 1.
     */
    function decrement() {
        setCount(getCount() - 1);
    }

    /**
     * Decrements the counter by 1.
     */
    function decrementWithDataDot(){
        data.count -= 1;
    }

    /**
     * Renders the component's HTML output with Livewire-compatible attributes.
     * @return The HTML representation of the component, including Livewire data attributes.
     */
    function renderIt() {
        return view("wires.Counter");
    }

}
