component extends="cbwire.models.Component" {

    // Data properties
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
}