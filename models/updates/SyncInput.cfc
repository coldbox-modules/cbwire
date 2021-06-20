
/**
 * Represents a syncInput update from the UI.
 */
component extends="LivewireUpdate"{

    /**
     * Applies this update to the specified component.
     * 
     * @comp cbLivewire.models.Component | Component we are updating.
     */
    function apply( required comp ){
           
        variables.$populator.populateFromStruct(
            target : arguments.comp,
            scope: "variables",
            memento : {
                "#this.getPayload()[ "name" ]#": "#this.getPayload()[ "value" ]#"
            },
            excludes : ""
        );

    }

}
            
