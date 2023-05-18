component {

	this.name = "testmodule";
	this.version = "1.0.0";
	this.author = "";
	this.webUrl = "";
	this.dependencies = [];

	/**
	 * This entry point remain as "livewire" as the underlining
	 * Livewire JS library has a hard dependency on this endpoint.
	 */
	this.entryPoint = "testmodule";

	this.layoutParentLookup = false;
	this.viewParentLookup = false;
	this.cfmapping = "testmodule";
	this.modelNamespace = "testmodule";
	this.applicationHelper = [];

	function configure(){
	}

}
