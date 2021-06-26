component extends="cbLivewire.models.Component"{

    property name="isChild" default="false";
    property name="message" default="";

    function $getListeners(){
        if ( variables.isChild ){
            return {};
        }
        return {
            "postAdded": "postAddedListener",
            "emitUpFired": "emitViaActionCall"
        };
    }

    function emitViaActionCall(){
        variables.message = "emitUpFired() fired!";
    }

    function emitViaAction(){
        this.$emitUp( "emitUpFired" );
    }

    function postAddedListener(){
        variables.message = "postAddedListener() fired!";
        this.$emitUp( "emitUpFired" );
    }

    function $renderIt() {
        return this.$renderView( "_cblivewire/emitUp" );
    }
}