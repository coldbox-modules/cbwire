/**
 * Represents an update to our UI which ultimately will update our cbwire component state.
 * This is primarily a parent object that is inherited from.
 */
component {

    // Injected populator.
    property
        name="$populator"
        inject="wirebox:populator";

    /**
     * Our beautiful constructor.
     *
     * @update Struct | Incoming request collection.
     */
    function init( required struct update ){
        variables.update = arguments.update;
    }

    /**
     * Returns the type of our update.
     *
     * @return String
     */
    function getType(){
        return variables.update.type;
    }

    /**
     * Returns true if the update matches the provided type.
     *
     * @checkType String | The type of update to check against.
     *
     * @return Boolean
     */
    function isType( checkType ){
        return arguments.checkType == this.getType();
    }

    /**
     * Returns true if the current update includes a payload.
     *
     * @return Boolean
     */
    function hasPayload(){
        return structKeyExists( variables.update, "payload" );
    }

    /**
     * Returns the cbwire payload sent over during the update.
     *
     * @return Struct
     */
    function getPayload(){
        return variables.update[ "payload" ];
    }

    /**
     * Applies this update to the specified component.
     *
     * @comp cbwire.models.Component | Component we're updating.
     */
    function apply( required comp ){
        // throw error to ensure that our child classes implement this
        throw( message = "This must be implemented in the child class." );
    }

}
