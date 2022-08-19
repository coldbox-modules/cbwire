component extends="cbwire.models.Component" {

    // Data properties
    data = {
        "conference": "Into The Box"
    };

    // Action modifying data property
    function addYear() {
        var currentYear = year( now() );
        if ( !find( currentYear, data.conference ) ) {
            data.conference &= " " & currentYear;
        }
    }

    function resetForm() {
        reset( "conference" );
    }
}