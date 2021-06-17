/**
public $search = '';
public $isActive = true;

public function resetFilters()
{
    $this->reset('search');
    // Will only reset the search property.

    $this->reset(['search', 'isActive']);
    // Will reset both the search AND the isActive property.
}

*/
component extends="cbLivewire.models.Component" accessors="true" {

    /**
     * Livewire properties
     */
    property name="name" default="test";

    /**
     * Render our livewire wire
     */
    function $renderIt(){
        return this.$view( "_cblivewire/resetPropertiesToInitialState" );
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