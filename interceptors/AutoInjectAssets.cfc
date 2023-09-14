component accessors="true"{

	property name="settings" inject="coldbox:modulesettings:cbwire";
    property name="cbwireService" inject="CBWIREService@cbwire";

    function preRender( event ) {
        if ( shouldInject( arguments.event ) ) {
            data.renderedContent = replaceNoCase( data.renderedContent, "</head>", getStyles() & chr( 10 ) & "</head>", "one" );
            data.renderedContent = replaceNoCase( data.renderedContent, "</body>", getScripts() & chr( 10 ) & "</body>", "one" );
        }
    }

    private function getStyles() {
        return cbwireService.getStyles();
    }

    private function getScripts() {
        return cbwireService.getScripts();
    }

    private function shouldInject( event ) {
        return arguments.event.getCurrentModule() != "cbwire" && getSettings().autoInjectAssets == true;
    }
}