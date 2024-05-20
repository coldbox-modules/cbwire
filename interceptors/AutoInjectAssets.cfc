component singleton {

	property name="settings" inject="coldbox:modulesettings:cbwire";
    property name="CBWIREController" inject="CBWIREController@cbwire";

    function preRender( event ) {
        if ( shouldInject( arguments.event ) ) {
            data.renderedContent = replaceNoCase( data.renderedContent, "</head>", getStyles() & chr( 10 ) & "</head>", "one" );
            data.renderedContent = replaceNoCase( data.renderedContent, "</body>", getScripts() & chr( 10 ) & "</body>", "one" );
        }
    }

    private function getStyles() {
        return variables.CBWIREController.getStyles();
    }

    private function getScripts() {
        return variables.CBWIREController.getScripts();
    }

    private function shouldInject( event ) {
        return arguments.event.getCurrentModule() != "cbwire" && variables.settings.autoInjectAssets == true;
    }
}