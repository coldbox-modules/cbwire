/**
 * Represents a syncInput update from the UI.
 */
component accessors="true" extends="BaseUpdate" {

	property name="populator" inject="wirebox:populator";

	/**
	 * Returns the field name.
	 *
	 * @return string
	 */
	function getName() {
		return getPayload()[ "name" ];
	}

	/**
	 * Returns the payload value
	 * 
	 * @return string
	 */
	function getValue() {
		return getPayload()[ "value" ];
	}

	/**
	 * Applies this update to the specified component.
	 *
	 * @comp cbwire.models.Component | Component we are updating.
	 */
	function apply( required comp ){
		getPopulator().populateFromStruct(
			target: arguments.comp,
			trustedSetter: true,
			memento: { "#getName()#" : "#getValue()#" },
			excludes: ""
		);

		// When syncing input, render our computed properties after the input has synced.
		arguments.comp._renderComputedProperties();
	}

}

