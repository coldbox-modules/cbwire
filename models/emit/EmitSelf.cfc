/**
 * Represent an emit to the component that fired the event.
 */
component extends="BaseEmit" {

    /**
     * Returns the emit result which get's included in the component's memento.
     *
     * @return Struct
     */
    function getResult(){
        return {
            "event" : this.getEventName(),
            "params" : variables.parameters,
            "selfOnly" : true
        };
    }

}
