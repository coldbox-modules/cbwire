component {

    function init() {
        variables.loops = [
            {
                "title": "Loop 1",
                "description": "A catchy hip hop beat with a BPM of 120",
                "bpm": 120,
                "genre": "Hip Hop"
            },
            {
                "title": "Loop 2",
                "description": "An energetic rock beat with a BPM of 140",
                "bpm": 140,
                "genre": "Rock"
            },
            {
                "title": "Loop 3",
                "description": "A lively pop beat with a BPM of 100",
                "bpm": 100,
                "genre": "Pop"
            },
            {
                "title": "Loop 4",
                "description": "A country-style beat with a BPM of 90",
                "bpm": 90,
                "genre": "Country"
            },
            {
                "title": "Loop 5",
                "description": "A soulful blues beat with a BPM of 130",
                "bpm": 130,
                "genre": "Blues"
            },
            {
                "title": "Loop 6",
                "description": "Another hip hop beat with a BPM of 110",
                "bpm": 110,
                "genre": "Hip Hop"
            },
            {
                "title": "Loop 7",
                "description": "A powerful rock beat with a BPM of 150",
                "bpm": 150,
                "genre": "Rock"
            },
            {
                "title": "Loop 8",
                "description": "A catchy pop beat with a BPM of 80",
                "bpm": 80,
                "genre": "Pop"
            },
            {
                "title": "Loop 9",
                "description": "A country-style beat with a BPM of 120",
                "bpm": 120,
                "genre": "Country"
            },
            {
                "title": "Loop 10",
                "description": "A soulful blues beat with a BPM of 140",
                "bpm": 140,
                "genre": "Blues"
            },
            {
                "title": "Loop 11",
                "description": "Another hip hop beat with a BPM of 100",
                "bpm": 100,
                "genre": "Hip Hop"
            },
            {
                "title": "Loop 12",
                "description": "An energetic rock beat with a BPM of 90",
                "bpm": 90,
                "genre": "Rock"
            },
            {
                "title": "Loop 13",
                "description": "A lively pop beat with a BPM of 130",
                "bpm": 130,
                "genre": "Pop"
            },
            {
                "title": "Loop 14",
                "description": "A country-style beat with a BPM of 110",
                "bpm": 110,
                "genre": "Country"
            },
            {
                "title": "Loop 15",
                "description": "A soulful blues beat with a BPM of 150",
                "bpm": 150,
                "genre": "Blues"
            },
            {
                "title": "Loop 16",
                "description": "Another hip hop beat with a BPM of 80",
                "bpm": 80,
                "genre": "Hip Hop"
            },
            {
                "title": "Loop 17",
                "description": "A powerful rock beat with a BPM of 120",
                "bpm": 120,
                "genre": "Rock"
            },
            {
                "title": "Loop 18",
                "description": "A catchy pop beat with a BPM of 140",
                "bpm": 140,
                "genre": "Pop"
            },
            {
                "title": "Loop 19",
                "description": "A country-style beat with a BPM of 100",
                "bpm": 100,
                "genre": "Country"
            },
            {
                "title": "Loop 20",
                "description": "A soulful blues beat with a BPM of 90",
                "bpm": 90,
                "genre": "Blues"
            },
            {
                "title": "Loop 21",
                "description": "Another hip hop beat with a BPM of 130",
                "bpm": 130,
                "genre": "Hip Hop"
            },
            {
                "title": "Loop 22",
                "description": "An energetic rock beat with a BPM of 110",
                "bpm": 110,
                "genre": "Rock"
            },
            {
                "title": "Loop 23",
                "description": "A lively pop beat with a BPM of 150",
                "bpm": 150,
                "genre": "Pop"
            },
            {
                "title": "Loop 24",
                "description": "A country-style beat with a BPM of 80",
                "bpm": 80,
                "genre": "Country"
            },
            {
                "title": "Loop 25",
                "description": "A soulful blues beat with a BPM of 120",
                "bpm": 120,
                "genre": "Blues"
            },
            {
                "title": "Loop 26",
                "description": "Another hip hop beat with a BPM of 140",
                "bpm": 140,
                "genre": "Hip Hop"
            },
            {
                "title": "Loop 27",
                "description": "An energetic rock beat with a BPM of 100",
                "bpm": 100,
                "genre": "Rock"
            },
            {
                "title": "Loop 28",
                "description": "A catchy pop beat with a BPM of 90",
                "bpm": 90,
                "genre": "Pop"
            },
            {
                "title": "Loop 29",
                "description": "A country-style beat with a BPM of 130",
                "bpm": 130,
                "genre": "Country"
            },
            {
                "title": "Loop 30",
                "description": "A soulful blues beat with a BPM of 110",
                "bpm": 110,
                "genre": "Blues"
            }
        ];
    }

    // Returns array of genres 
    function getGenres() {
        var genres = variables.loops.reduce( function( genres, beat ) {
            if ( genres.indexOf( beat.genre ) == -1 ) {
                genres.append( beat.genre );
            }
            return genres;
        }, [] );

        // Sort alphabetically
        return genres.sort( function( a, b ) {
            return a.compare( b );
        });
    }

    // Retrieves all loops
    function getloops() {
        return variables.loops;
    }

    // Adds a new beat to the array
    function addLoop(loop) {
        variables.loops.append( arguments.beat );
    }

    // Removes a beat from the array
    function removeLoop(loop) {
        throw( message="not implemented yet" );
    }

}