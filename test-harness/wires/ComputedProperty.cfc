component extends="cbwire.models.Component" {

    // Data properties
    this.$data = {
        "timestamp" : now(),
        "myQuery" : ""
    };

    // Computed properties
    this.$computed = {
        "myTimestamp" : function(){
            return this.$data.timestamp;
        }
    }

    function $renderIt(){
        return this.$renderView( "_wires/computedProperty" );
    }

}
