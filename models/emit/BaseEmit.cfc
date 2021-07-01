/**
 * Represent an base emit that all emitters inherit from.
 */
component {

    /**
     * Beautiful constructor
     *
     * @eventName String | The name of our event.
     * @parameters Array - The Emitter's parameters.
     */
    function init(
        required eventName,
        parameters = []
    ){
        variables.eventName = arguments.eventName;
        variables.parameters = arguments.parameters;
        return this;
    }

    /**
     * Returns the eventName passed in with the parameters to the emitter.
     *
     * @return String
     */
    function getEventName(){
        return variables.eventName;
    }

    /**
     * Returns the emitter result.
     *
     * @return Struct
     */
    function getResult(){
        return {
            "event" : this.getEventName(),
            "params" : variables.parameters
        };
    }

}
