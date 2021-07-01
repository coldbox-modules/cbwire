component
    extends="cbwire.models.Component"
    accessors="true"
{

    /**
     * cbwire properties
     */
    property
        name="name"
        default="test";

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
        setName( "Blah #now()#" );
    }

    /**
     * Reset our name property
     */
    function resetName(){
        this.$reset( "name" );
    }

}
