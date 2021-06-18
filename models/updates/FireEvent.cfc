component extends="LivewireUpdate"{

    /**
     * Applies this update to the specified component.
     * 
     * @comp cbLivewire.models.Component | Component we are updating.
     */
    function apply( required comp ){

        if ( !arguments.comp.$hasListeners() ){
            return;
        }

        var listeners = arguments.comp.$getListeners();

        var fireEventName = structKeyExists( listeners, this.getPayload()[ "event" ] ) ? listeners[ this.getPayload()[ "event" ] ] : "";

        if ( len( fireEventName ) && arguments.comp.$hasMethod( fireEventName )){
            return arguments.comp[ fireEventName ]();
        }

        throw( message="Couldn't find a event definition." );

    }
    
}