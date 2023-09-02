component accessors="true" {

	property name="wirebox" inject="wirebox";

	property name="engine";
	property name="data";
	property name="listeners";
	property name="computed";
	property name="template";
	property name="queryString";

	/**
	 * A beautiful start.
	 */
	function startup(){
		var engine = wirebox
			.getInstance( "ComponentEngine@cbwire" )
			.start( parent = this, parentCFCPath = getCurrentTemplatePath() );
		setEngine( engine );
		return engine;
	}

	/**
	 * PUBLIC METHODS for Wires
	 */

    function emit( required eventName ){
		return getEngine().emit( argumentCollection = arguments );
	}

	function emitSelf( required eventName ){
		return getEngine().emitSelf( argumentCollection = arguments );
	}

	function emitUp( required eventName ){
		return getEngine().emitUp( argumentCollection = arguments );
	}

	function emitTo( required componentName, required eventName ){
		return getEngine().emitTo( argumentCollection = arguments );
	}

	function getInstance( name, initArguments = {}, dsl ){
		return getEngine().getInstance( argumentCollection = arguments );
	}

	function getValidationManager(){
		return getEngine().getValidationManager();
	}

	function noRender() {
		return getEngine().noRender( argumentCollection=arguments );
	}

	function refresh() {
		return getEngine().refresh( argumentCollection=arguments );
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
		return getEngine().relocate( argumentCollection = arguments );
	}

	function renderView(){
		return getEngine().renderView( argumentCollection = arguments );
	}

	function reset( property ){
		return getEngine().reset( argumentCollection=arguments );
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
		return getEngine().validateOrFail( argumentCollection=arguments );
	}

	/**
	 * Catch methods called that don't exist
	 *
	 * @missingMethodName
	 * @missingMethodArguments
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments ){
		if ( structKeyExists( getEngine(), missingMethodName ) ) {
			return invoke( getEngine(), missingMethodName, missingMethodArguments );
		}
		return getEngine().onMissingMethod( argumentCollection = arguments );
	}

}
