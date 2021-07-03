component
    extends="cbwire.models.Component"
{

    this.$data = {
        "name": "test"
    };

    /**
     * Render our wire object.
     */
    function $renderIt(){
        return this.$view( "_wires/resetPropertiesToInitialState" );
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
        this.$reset( "name" );
    }

}
