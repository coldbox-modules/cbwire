component extends="cbwire.models.Component" {

    data = {
        "onUpdateMessage": false,
        "onUpdate": false,
        "message": ""
    };

    function onUpdate() {
        data.onUpdate = true;
    }

    function onUpdateMessage(){
        data.onUpdateMessage = true;
    }

    function onRender( args ) {
        return "
            <div>
                <div>onUpdate() called: #args.onUpdate#</div>
                <div>onUpdateMessage() called: #args.onUpdateMessage#</div>
                <div><input type='text' wire:model='message'></div>
            </div>
        ";
    }
}