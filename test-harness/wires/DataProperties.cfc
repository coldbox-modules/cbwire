component extends="cbwire.models.Component" {

    // Data properties
    data = {
        "conference": "Into The Box 2022",
        "toggleValue" : "false"
    };

    computed = {
        "someComputedProp": function( data ) {
            return data.conference & " yep ";
        }
    }

}