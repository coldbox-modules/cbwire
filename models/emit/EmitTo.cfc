/**
 * Represent an emit to a specific component.
 */
component extends="BaseEmit" {

	/**
	 * Beautiful constructor
	 *
	 * @eventName String | The name of our event.
	 * @parameters Array - The Emitter's parameters.
	 */
	function init( required eventName, required componentName, parameters = [] ){
		variables.eventName = arguments.eventName;
		variables.componentName = arguments.componentName;
		variables.parameters = arguments.parameters;
		return this;
	}

	/**
	 * Returns the emit result which get's included in the component's memento.
	 *
	 * @return Struct
	 */
	function getResult(){
		return {
			"event" : this.getEventName(),
			"params" : variables.parameters,
			"to" : variables.componentName
		};
	}

}
