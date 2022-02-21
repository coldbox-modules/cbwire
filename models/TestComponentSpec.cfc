component extends="testbox.system.BaseSpec" accessors="true"{

    property name="wirebox" inject="wirebox";

    property name="cbwireManager" inject="CBWireManager@cbwire";

	/**
	 * Injected RequestService so that we can access the current ColdBox RequestContext.
	 */
	property name="requestService" inject="coldbox:requestService";

    property name="isSubsequentRender" default="false";

    property name="componentName";

    property name="parameters";

    property name="hydrationCollection";

    property name="cbwireInstance";

    property name="rendering";

    function init( componentName, parameters = {} ) {
        setComponentName( arguments.componentName );
        setParameters( arguments.parameters );
        setHydrationCollection( 
            {
                "fingerprint": {
                    "path": "",
                    "locale": "en",
                    "method": "GET",
                    "id": "some-id",
                    "name": arguments.componentName
                },
                "serverMemo": {
                    "checksum": "some-checksum",
                    "errors": [],
                    "data": {},
                    "dataMeta": [],
                    "htmlHash": "some-htmlHash",
                    "children": []
                },
                "updates": []
            }
         );
        return this;
    }

    function set( required name, required value ){
        setIsSubsequentRender( true );
        getHydrationCollection()[ "serverMemo" ][ "data" ][ name ] = value;
        return this;
    }

    function toggle( required name ){
        var data = data();
        if ( structKeyExists( data, name ) && isBoolean( data[ name ] ) ){
            data[ name ] = !data[ name ];
        }
        return this;
    }

    function render(){
        if ( getIsSubsequentRender() ) {
            var event = requestService.getContext();
            var rc = event.setContext( getHydrationCollection() );
            var cbwireComponent = getWireInstance();
            var memento = cbwireComponent.$hydrate().subsequentRenderIt().$getMemento();
            setRendering( memento[ "effects" ][ "html" ] );
            return memento[ "effects" ][ "html" ];
        } else {
            var cbwireComponent = getWireInstance();
            var rendering = cbwireComponent.$mount( getParameters() ).renderIt();
            setRendering( rendering );
            return cbwireComponent.$mount( getParameters() ).renderIt();
        }
    }

    function call( required action, parameters = [] ) {
        setIsSubsequentRender( true );
        getHydrationCollection()[ "updates" ].append( {
            "type": "callMethod",
            "payload": {
                "id": "nbk1",
                "method": arguments.action,
                "params": arguments.parameters
            }
        } );
        return this;
    }

    function emit( required event, parameters = [] ) {
        setIsSubsequentRender( true );
        getHydrationCollection()[ "updates" ].append( {
            "type": "fireEvent",
            "payload": {
                "id": "nbk1",
                "event": arguments.event,
                "params": arguments.parameters
            }
        } );
        return this;
    }

    function assertSee( required needle ) {
        render();
        expect( getRendering() ).toInclude( needle );
    }

    function assertDontSee( required needle ) {
        render();
        expect( getRendering() ).notToInclude( needle );
    }

    function assertSet( required dataProperty, required value ){
        render();
        expect( data()[ dataProperty ] ).toBe( value );
    }

    function assertNotSet( required dataProperty, required value  ) {
        render();
        expect( data()[ dataProperty ] ).notToBe( value );
    }

    private function data() {
        return getWireInstance().getDataProperties();
    }

    private function getWireInstance() {
        if ( isNull( getCBWireInstance() ) ){
            setCBWireInstance( cbwireManager.getComponentInstance( getComponentName() ) );
        }
        return getCBWireInstance();
    }

}