component accessors="true" {
    
    property name="event" type="RequestContext";

    function init( RequestContext event ) {
        setEvent( arguments.event );
        return this;
    }

    function hasFingerprint() {
        return structKeyExists( getCollection(), "fingerprint" );
    }  

    function hasServerMemo() {
        return structKeyExists( getCollection(), "serverMemo" );
    }

    function getServerMemo() {
        return getCollection().serverMemo;
    }

    function hasUpdates() {
        return structKeyExists( getCollection(), "updates" );
    }

    function getCollection() {
        return getEvent().getCollection( argumentsCollection=arguments );
    }

}