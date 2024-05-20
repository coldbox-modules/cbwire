component extends="cbwire.models.Component" {

    property name="beatBoxService" inject="BeatBoxService";

    data = {
        "genres": [],
        "loops": []
    };

    function onMount( event, rc, prc ) {
        sleep( 3000 ); // slow database
        data.genres = beatBoxService.getGenres();
        data.loops = beatBoxService.getLoops();
    }

    function placeholder() {
        return "Loading...";
    }
}