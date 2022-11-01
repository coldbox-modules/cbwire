component extends="cbwire.models.Component" {

    // Computed properties
    computed = {
        "conference": function() {
            return "Into The Box " & year( now() );
        },
        "speakers": getSpeakers,
        "nullComputedProperty": function() {
            return;
        }
    }

    function getSpeakers() {
        return queryNew( 
            "firstname,lastname",
            "varchar,varchar",
            [
                {
                    "firstname": "Abram",
                    "lastname": "Adams"
                }, 
                {
                    "firstname": "Brad",
                    "lastname": "Wood"
                }, 
                {
                    "firstname": "Brian",
                    "lastname": "Rinaldi"
                }, 
                {
                    "firstname": "Charlie",
                    "lastname": "Arehart"
                }, 
                {
                    "firstname": "Dan",
                    "lastname": "Card"
                }, 
                {
                    "firstname": "Daniel",
                    "lastname": "García"
                }, 
                {
                    "firstname": "Eric",
                    "lastname": "Peterson"
                }, 
                {
                    "firstname": "Esmeralda",
                    "lastname": "Acevedo"
                }, 
                {
                    "firstname": "Gavin",
                    "lastname": "Pickin"
                }, 
                {
                    "firstname": "George",
                    "lastname": "Murphy"
                }, 
                {
                    "firstname": "Grant",
                    "lastname": "Copley"
                }, 
                {
                    "firstname": "Javier",
                    "lastname": "Quintero"
                }, 
                {
                    "firstname": "John",
                    "lastname": "Farrar"
                }, 
                {
                    "firstname": "Jon",
                    "lastname": "Clausen"
                }, 
                {
                    "firstname": "Kai",
                    "lastname": "Koenig"
                }, 
                {
                    "firstname": "Luis",
                    "lastname": "Majano"
                }, 
                {
                    "firstname": "Mark",
                    "lastname": "Takata"
                }, 
                {
                    "firstname": "Matthew",
                    "lastname": "Clemente"
                }, 
                {
                    "firstname": "Michael",
                    "lastname": "Born"
                }, 
                {
                    "firstname": "Nolan",
                    "lastname": "Erck"
                }, 
                {
                    "firstname": "Raymond",
                    "lastname": "Camden"
                }, 
                {
                    "firstname": "Scott",
                    "lastname": "Steinbeck"
                }, 
                {
                    "firstname": "Seth",
                    "lastname": "Stone"
                }, 
                {
                    "firstname": "Shawn",
                    "lastname": "Oden"
                }, 
                {
                    "firstname": "Zac",
                    "lastname": "Spitzer"
                }
            ]
        );
    }

}