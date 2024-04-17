component accessors="true"{

    property name="cbwireController" inject="CBWIREController@cbwire";

    property name="payload";

    /**
     * Passes in a payload sent by the browser.
     * 
     * @return void
     */
    function withPayload( required struct payload ){
        setPayload( arguments.payload );
        return this;
    }


    /**
    * Returns the response for subsequent requests of components.
    * 
    * @returns struct 
    */
    function getResponse(){
        return {
            "components": getPayload().components.map( ( _componentPayload ) => {
                // Locate the component and instantiate it.
                var componentInstance = getCBWIREController()
                                            .createInstance( _componentPayload.snapshot.memo.name );
                // Return the response for this component
                return componentInstance
                            ._asSubsequentRequest()
                            ._getHTTPResponse( _componentPayload );
            } )
        };
    }
}