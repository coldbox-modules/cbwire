component extends="cbwire.models.Component" accessors="true" {

    property name="conference" default="Into the box";
    property name="toggleValue" default="false";

    computed = {
        "someComputedProp": function( data ) {
            return data.conference & " yep ";
        }
    }

    function getConference(){
        return "test";
    }

}