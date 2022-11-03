component extends="cbwire.models.Component" {

    data = {
        "hydrated": false
    };

    function clicked() {}

    function onHydrate( data, computed ) {
        data.hydrated = true;
    }

    function onRender( args ) {
        return "
            <div>
                <div>Hydrated: #args.hydrated#</div>
                <button wire:click='clicked'>Click me</button>
            </div>
        ";
    }
}