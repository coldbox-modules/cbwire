component extends="cbwire.models.Component" {

    data = {
        "isChild" : false,
        "message" : ""
    };

    function $getListeners(){
        if ( data.isChild ){
            return {};
        }
        return {
            "postAdded" : "postAddedListener",
            "emitUpFired" : "emitViaActionCall"
        };
    }

    function emitViaActionCall(){
        data.message = "emitUpFired() fired!";
    }

    function emitViaAction(){
        this.emitUp( "emitUpFired" );
    }

    function postAddedListener(){
        data.message = "postAddedListener() fired!";
        this.emitUp( "emitUpFired" );
    }

    function renderIt(){
        return this.renderView( "_wires/emitUp" );
    }

}
