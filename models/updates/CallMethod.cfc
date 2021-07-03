component extends="WireUpdate" {

    /**
     * Applies this update to the specified component.
     *
     * @comp cbwire.models.Component | Component we are updating.
     */
    function apply( required comp ){
        this.invokeComponentMethod( arguments.comp );
    }

}
