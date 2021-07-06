component extends="cbwire.models.Component" {

    variables.$data = {
        "isChild" : false,
        "message" : ""
    };

    function $getListeners(){
        if ( variables.$data.isChild ){
            return {};
        }
        return {
            "postAdded" : "postAddedListener",
            "emitUpFired" : "emitViaActionCall"
        };
    }

    function emitViaActionCall(){
        variables.$data.message = "emitUpFired() fired!";
    }

    function emitViaAction(){
        this.$emitUp( "emitUpFired" );
    }

    function postAddedListener(){
        variables.$data.message = "postAddedListener() fired!";
        this.$emitUp( "emitUpFired" );
    }

    function $renderIt(){
        return this.$renderView( "_wires/emitUp" );
    }

}
