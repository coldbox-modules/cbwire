component {

	// Module Properties
	this.title 				= "testingmodule";
	this.author 			= "";
	this.webURL 			= "";
	this.description 		= "";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "testingmodule";
	// Inherit Entry Point
	this.inheritEntryPoint 	= false;
	// Model Namespace
	this.modelNamespace		= "testingmodule";
	// CF Mapping
	this.cfmapping			= "testingmodule";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies
	this.dependencies 		= [];

	function configure(){

		// parent settings
		parentSettings = {

		};

		settings = {

		};

		layoutSettings = {
			defaultLayout = "Main.cfm"
		};

		routes = [];

		resources = [];

		interceptorSettings = {
			customInterceptionPoints = ""
		};

		interceptors = [];

	}

}
