component
    extends="cbwire.models.Component"
    accessors="true"
{

    /**
     * Livewire properties
     */
    property
        name="name"
        default="test";

    /**
     * Render our livewire wire
     */
    function $renderIt(){
        return this.$view( "_cbwire/resetPropertiesToInitialState" );
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
