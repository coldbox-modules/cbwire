component extends="cbwire.models.Component" {

    data = [
        "title": "CBWIRE Rocks!",
        "states": []
    ];

    function addState( abr, name ){
        data.states.append( { "name" : name, "abr" : abr } );
    }

    function onMount( params, event, rc, prc ) {
        // Initialize some states
        data.states.append( { "name" : "Maryland", "abr" : "MD" } );
        data.states.append( { "name" : "Virginia", "abr" : "VA" } );
        data.states.append( { "name" : "Florida", "abr" : "FL" } );
        data.states.append( { "name" : "Wyoming", "abr" : "WY" } );
    }

}