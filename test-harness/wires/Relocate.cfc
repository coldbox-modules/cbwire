component
    extends="cbwire.models.Component"
    accessors="true"
{

    function goElsewhere(){
        return relocate( url = "https://www.google.com" );
    }

    function onRender(){
        return renderView( "wires/relocate" );
    }

}
