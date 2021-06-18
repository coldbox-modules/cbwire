component extends="LivewireUpdate"{

    /**
     * Applies this update to the specified component.
     * 
     * @comp cbLivewire.models.Component | Component we are updating.
     */
    function apply( required comp ){
        if ( this.hasCallableMethod( arguments.comp ) ) {
            this.invokeComponentMethod( arguments.comp );
            return;
        }

        throw(type="LivewireMethodNotFound", message="Method '" & this.getPayloadMethod() & "' not found on your component." );
    }
    
}