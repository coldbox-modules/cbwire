component extends="cbwire.models.v4.Component" accessors="true" {

    data = {
        "conference": "Into the box",
        "toggleValue": false
    };

    computed = {
        "someComputedProp": function( data ) {
            return data.conference & " yep ";
        }
    }

    function getConference(){
        return "test";
    }

}