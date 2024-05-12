component {

    property name="beatBoxService" inject="BeatBoxService";

    function preHandler( event ) {
        event.setLayout( "BeatBox" );
    }

    function index( event, rc, prc ) {}

    function loops( event, rc, prc ) {
        prc.searchCriteria = event.getValue( "search", "" );
        prc.genreCriteria = event.getValue( "genre", "" );
        prc.genres = beatBoxService.getGenres();
        prc.loops = beatBoxService.getLoops();

        // Filter our loops by the search criteria.
        if ( prc.searchCriteria.len() ) {
            prc.loops = prc.loops.filter( function( _loop ) {
                return _loop.title contains prc.searchCriteria;
            } );
        }

        // Filter our loops by the genre.
        if ( prc.genreCriteria.len() ) {
            prc.loops = prc.loops.filter( function( _loop ) {
                return _loop.genre contains prc.genreCriteria;
            } );
        }
    }

    function upload( event, rc, prc ) {}

    function contact( event, rc, prc ) {}
}