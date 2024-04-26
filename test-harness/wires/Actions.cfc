component extends="cbwire.models.v4.Component" {

    data = {
        "conference": "Into The Box"
    };

    // Actions
    function changeConference() {
        data.conference = "CF Summit";
    }

    function addYear( currentYear ) {
        data.conference &= " " & currentYear;
    }

    function resetConference() {
        reset( "conference" );
    }

    function renderIt(){
        return view( "wires.actions" );
    }
}