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

    function renderIt(){
        return this.renderView( "wires/computedProperty" );
    }

}
