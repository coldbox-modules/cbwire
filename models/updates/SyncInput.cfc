/**
 * Represents a syncInput update from the UI.
 */
component extends="WireUpdate" {

    /**
     * Applies this update to the specified component.
     *
     * @comp cbwire.models.Component | Component we are updating.
     */
    function apply( required comp ){       
        variables.$populator.populateFromStruct(
            target: arguments.comp,
            trustedSetter: true,
            memento: { "#this.getPayload()[ "name" ]#" : "#this.getPayload()[ "value" ]#" },
            excludes: ""
        );

    }

}

