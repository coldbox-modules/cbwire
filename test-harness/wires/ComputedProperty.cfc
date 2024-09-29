component extends="cbwire.models.Component" {

    // Data properties
    data = {
        "timestamp" : now(),
        "myQuery" : ""
    };

    // Computed properties
    computed = {
        "myTimestamp" : function(){
            return data.timestamp;
        }
    }

    function onRender(){
        return this.renderView( "wires/computedProperty" );
    }

}
