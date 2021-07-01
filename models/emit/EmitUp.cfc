/**
 * Represent an emit to any parent components from the current component.
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
            "ancestorsOnly" : true
        };
    }

}
