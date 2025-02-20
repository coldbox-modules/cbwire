<cfscript>
    // @startWire
    data = {
        "hydrated": false,
        "hydratedProperty": false
    };
    
    function clicked() {}
    
    function onHydrate() {
        data.hydrated = true;
    }
    
    function onHydrateHydrated(){
        data.hydratedProperty = true;
    }
    // @endWire
</cfscript>

<cfoutput>
    <div>
        <div>Hydrated: #hydrated#</div>
        <div>Hydrated Property: #hydratedProperty#</div>
        <button wire:click='clicked'>Click me</button>
    </div>
</cfoutput>
