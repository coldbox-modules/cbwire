component extends="cbLivewire.models.Component" accessors="true" {

    this.$listeners = {
        "postAdded": "blah"
    };

    function $renderIt(){
        return this.$renderView( "_cbLivewire/emitFromButton" );
    }
}