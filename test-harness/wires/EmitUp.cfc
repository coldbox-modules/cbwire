component extends="cbwire.models.Component" {

    this.$data = {
        "isChild": false,
        "message": ""
    };

    function $getListeners(){
        if ( this.$data.isChild ){
            return {};
        }
        return {
            "postAdded" : "postAddedListener",
            "emitUpFired" : "emitViaActionCall"
        };
    }

    function emitViaActionCall(){
        this.$data.message = "emitUpFired() fired!";
    }

    function emitViaAction(){
        this.$emitUp( "emitUpFired" );
    }

    function postAddedListener(){
        this.$data.message = "postAddedListener() fired!";
        this.$emitUp( "emitUpFired" );
    }

    function $renderIt(){
        return this.$renderView( "_wires/emitUp" );
    }

}
