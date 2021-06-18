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

        var eventName = this.getPayload()[ "event" ];

        arguments.comp.$emit( eventName );
    }
    
}