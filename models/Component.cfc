component accessors="true" {

	property name="wirebox" inject="wirebox";

	property name="renderer";
	property name="data";
	property name="listeners";
	property name="computed";
	property name="template";
	property name="queryString";
	property name="inlineComponentID" default="";
	property name="inlineComponentType" default="";
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

	function isInlineComponent() {
		return getInlineComponentID().len() ? true : false ;
	}

	function noRender() {
		return getRenderer().noRender( argumentCollection=arguments );
	}

	function refresh() {
		return getRenderer().refresh( argumentCollection=arguments );
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
		return getRenderer().renderView( argumentCollection = arguments );
	}

	function reset( property ){
		return getRenderer().reset( argumentCollection=arguments );
	}

	function validateOrFail(
		any target,
		string fields        = "*",
		any constraints      = "",
		string locale        = "",
		string excludeFields = "",
		string includeFields = "",
		string profiles      = ""
	){
		return getRenderer().validateOrFail( argumentCollection=arguments );
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
