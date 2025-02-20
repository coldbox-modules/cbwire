component extends="cbwire.models.Component" {

    data = { "name" : "test" };

    /**
     * Render our wire object.
     */
    function onRender(){
        return this.renderView( "wires/resetPropertiesToInitialState" );
    }

    /**
     * Changes our name
     */
    function changeName(){
        this.setName( "Blah #now()#" );
    }

    /**
     * Reset our name property
     */
    function resetName(){
        reset( "name" );
    }

}
