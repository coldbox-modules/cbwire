/**
 * Represents a subsequent, incoming cbwire XHR Request from the browser.
 */
component
    accessors="true"
    singleton
{

    /**
     * Hold a reference to the cbwire component we are updating.
     */
    property name="component";

    /**
     * Injected ColdBox controller which we will use to access our app and module settings
     */
    property
        name="controller"
        inject="coldbox";

    /**
     * Injected WireBox because DI rocks.
     */
    property
        name="wirebox"
        inject="wirebox";

    /**
     * Injected RequestService so that we can access the current ColdBox RequestContext.
     */
    property
        name="requestService"
        inject="coldbox:requestService";

    /**
     * Injected settings.
     */
    property
        name="$settings"
        inject="coldbox:modulesettings:cbwire";

    /**
     * Returns the current ColdBox RequestContext event.
     *
     * @return RequestContext
     */
    function getEvent(){
        return variables.requestService.getContext();
    }

    /**
     * Returns true if our request context contains a 'fingerprint' property.
     *
     * @return Boolean
     */
    function hasFingerprint(){
        return structKeyExists( this.getCollection(), "fingerprint" );
    }

    /**
     * Returns true if our request context contains a 'serverMemo' property.
     *
     * @return Boolean
     */
    function hasServerMemo(){
        return structKeyExists( this.getCollection(), "serverMemo" );
    }

    /**
     * Returns true if our server memo contains a mounted state property.
     *
     * @return Boolean
     */
    function hasMountedState(){
        return this.hasServerMemo() && structKeyExists( this.getServerMemo(), "mountedState" );
    }

    /**
     * Returns our mounted state
     *
     * @return Struct
     */
    function getMountedState(){
        return this.getServerMemo()[ "mountedState" ];
    }

    /**
     * Returns the serverMemo from our request context.
     *
     * @return struct
     */
    function getServerMemo(){
        return this.getCollection()[ "serverMemo" ];
    }

    /**
     * Returns true if our request context contains an 'updates' property.
     *
     * @return Boolean
     */
    function hasUpdates(){
        var collection = this.getCollection();
        return structKeyExists( collection, "updates" ) && isArray( collection.updates ) && arrayLen(
            collection.updates
        );
    }

    /**
     * Returns an array of WireUpdate objects with our updates from the request context.
     *
     * @return Array | WireUpdate
     */
    function getUpdates(){
        return this.getCollection()[ "updates" ].map( function( update ){

            var casedType = arguments.update.type;

            casedType = reReplaceNoCase( casedType, "^(.)", "\U\1", "one" );

            return variables.wirebox.getInstance(
                name = "cbwire.models.updates.#arguments.update.type#",
                initArguments = { "update" : arguments.update }
            );
        } );
    }

    /**
     * Returns our event's public request collection.
     *
     * @return Struct
     */
    function getCollection(){
        return getEvent().getCollection( argumentCollection = arguments );
    }

    /**
     * Returns our event's private request collection.
     *
     * @return Struct
     */
    function getPrivateCollection(){
        return getEvent().getPrivateCollection( argumentCollection = arguments );
    }

    /**
     * Finds and returns our cbwire component by name, either using
     * module syntax Component@Module or root sytax, which looks
     * in the root "wires" folder by default.
     *
     * The folder can be overridden with the 'componentLocation' setting.
     *
     * @componentName String | The name of the component.
     */
    function withComponent( componentName ){
        // Determine our component location from the cbwire settings.
        var componentLocation = variables.getComponentLocation();

        if ( reFindNoCase( componentLocation & "\.", arguments.componentName ) ){
            arguments.componentName = reReplaceNoCase(
                arguments.componentName,
                componentLocation & "\.",
                "",
                "one"
            );
        }

        if ( find( "@", arguments.componentName ) ){
            // This is a module reference, find in our module
            var comp = getModuleComponent( arguments.componentName );
        } else{
            // Look in our root folder for our cbwire component
            var comp = getRootComponent( arguments.componentName );
        }

        variables.setComponent( comp );

        return this;
    }

    /**
     * Instantiates our cbwire component, mounts it,
     * and then calls it's internal renderIt() method.
     *
     * @componentName String | The name of the component in your cbwire folder.
     * @parameters Struct | The parameters you want mounted initially.
     *
     * @return Component
     */
    function renderIt( componentName, parameters = {} ){
        return withComponent( arguments.componentName )
            .getComponent()
            .$mount( arguments.parameters )
            .renderIt();
    }

    /**
     * Applies any updates in our request to the specified cbwire component
     *
     * @comp cbwire.models.Component
     *
     * @return Void
     */
    function applyUpdates( comp ){
        // Fire our preUpdate lifecycle event.
        arguments.comp.invokeMethod( "preUpdate" );

        // Update the state of our component with each of our updates
        this.getUpdates()
            .each( function( update ){
                update.apply( comp );
            } );

        // Fire our postUpdate lifecycle event.
        arguments.comp.invokeMethod( "preUpdate" );
    }

    /**
     * Hydrates the incoming component with state from our request.
     *
     * @return Component
     */
    function hydrate(){
        var comp = variables.getComponent();

        // Invoke '$preHydrate' event
        comp.invokeMethod( "$preHydrate" );

        if ( this.hasMountedState() ){
            comp.setMountedState( this.getMountedState() );
        }

        // Check if our request contains a server memo, and if so update our component state.
        if ( this.hasServerMemo() ){
            this.getServerMemo()
                .data
                .each( function( key, value ){
                    // Call the setter method
                    comp.invokeMethod( methodName = "set" & arguments.key, value = arguments.value );
                } );
        }

        // Invoke '$postHydrate' event
        comp.invokeMethod( "$postHydrate" );

        // Check if our request contains updates, and if so apply them.
        if ( this.hasUpdates() ){
            this.applyUpdates( comp );
        }

        return this;
    }

    /**
     * Returns the memento for our component which holds the current
     * state of our component. This is returned on subsequent XHR requests
     * from cbwire.
     *
     * @return Struct
     */
    function getMemento(){
        var comp = getComponent();

        return {
            "effects" : {
                "html" : comp.getRendering(),
                "dirty" : [
                    "count" // need to fix
                ],
                "path" : comp.getPath(),
                "emits" : comp.getEmits()
            },
            "serverMemo" : {
                "htmlHash" : "71146cf2",
                "data" : comp.getState(),
                "checksum" : comp.getChecksum(),
                "mountedState" : this.getMountedState()
            }
        }
    }

    /**
     * Returns a cbwire component using the root "HelloWorld" convention.
     *
     * @componentName String | Name of the cbwire component.
     *
     * @return Component
     */
    private function getRootComponent( required componentName ){
        var appMapping = variables.controller.getSetting( "AppMapping" );
        var wireRoot = ( len( appMapping ) ? appMapping & "." : "" ) & "wires";
        return variables.wirebox.getInstance( "#wireRoot#.#arguments.componentName#" );
    }

    /**
     * Returns a cbwire component using the module convention.
     *
     * @componentName String | Name of the cbwire component and module.
     *
     * @return Component
     */
    private function getModuleComponent( required componentName ){
        throw( message = "Need to finish implementing this" );
        // Verify the module
        variables.modulesConfig.keyExists( moduleName ); // else throw exception
        // Instantion Prefix of the module
        var wireModuleRoot = variables.modulesConfig[ moduleName ].invocationPath & ".wires";

        throw( message = "Need to finish!" );
    }

    /**
     * Returns the cbwire component location setting.
     *
     * @return String
     */
    private function getComponentLocation(){
        return variables.$settings.componentLocation;
    }

}
