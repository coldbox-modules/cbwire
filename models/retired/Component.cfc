component accessors="true" {

	property name="wirebox" inject="wirebox";

	property name="renderer";
	property name="data";
	property name="listeners";
	property name="computed";
	property name="template";
	property name="constraints";
	property name="queryString";
	property name="singleFileComponentID" default="";
	property name="singleFileComponentType" default="";
	property name="module" default="";

	/**
	 * A beautiful start.
	 */
	function startup( initialRender = true ){
		var rendererType = arguments.initialRender ? "InitialRenderer@cbwire" : "SubsequentRenderer@cbwire";
		var renderer = wirebox
			.getInstance( rendererType )
			.start( parent = this, parentCFCPath = getCurrentTemplatePath() );
		setRenderer( renderer );
		return renderer;
	}

	/**
	 * PUBLIC METHODS for Wires
	 */
	function dispatch( required eventName, parameters = {} ){
		return getRenderer().dispatch( argumentCollection = arguments );
	}

	function emit( required eventName ){
		return getRenderer().emit( argumentCollection = arguments );
	}

	function emitSelf( required eventName ){
		return getRenderer().emitSelf( argumentCollection = arguments );
	}

	function emitUp( required eventName ){
		return getRenderer().emitUp( argumentCollection = arguments );
	}

	function emitTo( required componentName, required eventName ){
		return getRenderer().emitTo( argumentCollection = arguments );
	}

	function getInstance( name, initArguments = {}, dsl ){
		return getRenderer().getInstance( argumentCollection = arguments );
	}

	function getValidationManager(){
		return getRenderer().getValidationManager();
	}

	function validate( target, fields, constraints, locale, excludeFields, includeFields, profiles ){
		return getRenderer().validate( argumentCollection=arguments );
	}

	function isSingleFileComponent(){
		return getSingleFileComponentID().len() ? true : false;
	}

	function noRender(){
		return getRenderer().noRender( argumentCollection = arguments );
	}

	function refresh(){
		return getRenderer().refresh( argumentCollection = arguments );
	}

	function $toggle(){
		return getRenderer().$toggle( argumentCollection=arguments );
	}

	function relocate(
		event = "",
		queryString = "",
		boolean addToken = false,
		persist = "",
		struct persistStruct = structNew()
		boolean ssl,
		baseURL = "",
		boolean postProcessExempt = false,
		URL,
		URI
	){
		return getRenderer().relocate( argumentCollection = arguments );
	}

	function renderView(){
		return getRenderer().view( argumentCollection = arguments );
	}

	function reset( property ){
		return getRenderer().reset( argumentCollection = arguments );
	}

	function resetExcept( property ){
		return getRenderer().resetExcept( argumentCollection = arguments );
	}

	function validateOrFail(
		any target,
		string fields = "*",
		any constraints = "",
		string locale = "",
		string excludeFields = "",
		string includeFields = "",
		string profiles = ""
	){
		return getRenderer().validateOrFail( argumentCollection = arguments );
	}

	/**
	 * Returns the meta information for the component
	 *
	 * @return struct 
	 */
	function getMetaInfo(){
		if ( !variables.keyExists( "metaInfo" ) ) {
			variables.metaInfo = getMetaData( this );
		}
		return variables.metaInfo;
	}

	/**
	 * Returns any properties defined on the component using
	 * the property tag.
	 *
	 * @return array 
	 */
	function getPropertyTagDataProperties(){
		var metaInfo = getMetaInfo();
		return metaInfo.properties.filter( function( prop ) {
			return !prop.keyExists( "inject" );
		} );
	}

	function getVariables() {
		return variables;
	}
	/**
	 * Catch methods called that don't exist
	 *
	 * @missingMethodName
	 * @missingMethodArguments
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments ){
		if ( structKeyExists( getRenderer(), missingMethodName ) ) {
			return invoke( getRenderer(), missingMethodName, missingMethodArguments );
		}
		return getRenderer().onMissingMethod( argumentCollection = arguments );
	}

}
