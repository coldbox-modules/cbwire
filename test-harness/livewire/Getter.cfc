component extends="cbLivewire.models.Component" accessors="true" {

    function mount(){
        variables.name = "Blah";
    }

    function getName(){
        return "Rubble On The Double";
    }

    function $renderIt() {
        return this.$renderView( "_cbLivewire/getter" );
    }
}