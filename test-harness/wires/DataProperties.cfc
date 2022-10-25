component extends="cbwire.models.Component" {

    // Data properties
    data = {
        "conference": "Into The Box 2022"
    };

    computed = {
        "someComputedProp": function( data ) {
            return data.conference & " yep ";
        }
    }

    function onRender( args ) {
        return "
            <div>
                <h1>Welcome To #args.conference#</h1>
                <h2>#args.someComputedProp#</h2>
            </div>
        ";
    }

}