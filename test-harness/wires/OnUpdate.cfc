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

    function renderIt() {
        return "
            <div>
                <div>onUpdate() called: #data.onUpdate#</div>
                <div>onUpdateMessage() called: #data.onUpdateMessage#</div>
                <div><input type='text' wire:model='message'></div>
            </div>
        ";
    }
}