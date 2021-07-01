component
    extends="cbLivewire.models.Component"
    accessors="true"
{

    function goElsewhere(){
        return this.$relocate( url = "https://www.google.com" );
    }

    function $renderIt(){
        return this.$renderView( "_cblivewire/relocate" );
    }

}
