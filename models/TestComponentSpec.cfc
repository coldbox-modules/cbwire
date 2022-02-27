component extends="testbox.system.BaseSpec" accessors="true" {

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

	property name="computed";

	property name="cbwireInstance";

	property name="rendering";

	function init( componentName, parameters = {} ){
		setComponentName( arguments.componentName );
		setParameters( arguments.parameters );
		setComputed( {} );
		setHydrationCollection( {
			"fingerprint" : {
				"path"   : "",
				"locale" : "en",
				"method" : "GET",
				"id"     : "some-id",
				"name"   : arguments.componentName
			},
			"serverMemo" : {
				"checksum" : "some-checksum",
				"errors"   : [],
				"data"     : {},
				"dataMeta" : [],
				"htmlHash" : "some-htmlHash",
				"children" : []
			},
			"updates" : []
		} );
		return this;
	}

	function data( required name, value ){
		setIsSubsequentRender( true );
		if ( isStruct( name ) ) {
			getHydrationCollection().serverMemo.data = name;
		} else {
			getHydrationCollection().serverMemo.data[ name ] = value;
		}
		return this;
	}

	function computed( required name, value ){
		if ( isStruct( name ) ) {
			setComputed( name );
		} else {
			var computed = getComputed();
			computed[ name ] = value;
		}
		return this;
	}

	function toggle( required name ){
		var data = getDataProperties();
		if ( structKeyExists( data, name ) && isBoolean( data[ name ] ) ) {
			data[ name ] = !data[ name ];
		}
		return this;
	}

	function renderIt(){
		if ( getIsSubsequentRender() ) {
			var event           = requestService.getContext();
			var rc              = event.setContext( getHydrationCollection() );
			var cbwireComponent = getWireInstance();
			if ( listLen( structKeyList( getComputed() ) ) ){
				cbwireComponent.set$ComputedProperties( getComputed() );
			}
			var memento         = cbwireComponent
				.$hydrate()
				.$subsequentRenderIt()
				.$getMemento();
			var html = memento[ "effects" ][ "html" ];
			setRendering( html );
			return html;
		} else {
			var cbwireComponent = getWireInstance();
			if ( listLen( structKeyList( getComputed() ) ) ){
				cbwireComponent.set$ComputedProperties( getComputed() );
			}	
			var rendering       = cbwireComponent.$mount( getParameters() ).renderIt();
			setRendering( rendering );
			return rendering;
		}
	}

	function call( required action, parameters = [] ){
		setIsSubsequentRender( true );
		getHydrationCollection()[ "updates" ].append( {
			"type"    : "callMethod",
			"payload" : {
				"id"     : "nbk1",
				"method" : arguments.action,
				"params" : arguments.parameters
			}
		} );
		return this;
	}

	function emit( required event, parameters = [] ){
		setIsSubsequentRender( true );
		getHydrationCollection()[ "updates" ].append( {
			"type"    : "fireEvent",
			"payload" : {
				"id"     : "nbk1",
				"event"  : arguments.event,
				"params" : arguments.parameters
			}
		} );
		return this;
	}

	function see( required needle ){
		renderIt();
		expect( getRendering() ).toInclude( needle );
	}

	function dontSee( required needle ){
		renderIt();
		expect( getRendering() ).notToInclude( needle );
	}

	function seeData(
		required dataProperty,
		required value
	){
		renderIt();
		expect( getDataProperties()[ dataProperty ] ).toBe( value );
	}

	function dontSeeData(
		required dataProperty,
		required value
	){
		renderIt();
		expect( getDataProperties()[ dataProperty ] ).notToBe( value );
	}

	private function getDataProperties(){
		return getWireInstance().get$DataProperties();
	}

	private function getComputedProperties(){
		return getWireInstance().get$ComputedProperties();
	}

	private function getWireInstance(){
		if ( isNull( getCBWireInstance() ) ) {
			setCBWireInstance( cbwireManager.getComponentInstance( getComponentName() ) );
		}
		return getCBWireInstance();
	}

}
