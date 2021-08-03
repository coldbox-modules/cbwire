component {

	this.name         = "cbwire";
	this.version      = "1.0.0";
	this.author       = "";
	this.webUrl       = "https://github.com/coldbox-modules/cbwire";
	this.dependencies = [];

	/**
	 * This entry point remain as "livewire" as the underlining
	 * Livewire JS library has a hard dependency on this endpoint.
	 */
	this.entryPoint = "livewire";

	this.layoutParentLookup = false;
	this.viewParentLookup   = false;
	this.cfmapping          = "cbwire";
	this.modelNamespace     = "cbwire";
	this.applicationHelper  = [ "helpers/helpers.cfm" ];

	function configure(){
		settings = {
			/**
			 * Set to true to throw a 'WireSetterNotFound' exception if
			 * the incoming cbwire request tries to update a property
			 * without a setter on our component. Otherwise, missing setters are ignored.
			 */
			"throwOnMissingSetterMethod" : false,
			/**
			 * The default folder name where your cbwire components are stored.
			 * Defaults to 'wires' folder.
			 */
			"componentLocation" : "wires"
		};

		routes = [
			{
				"pattern" : "message/:wireComponent",
				"handler" : "Main"
			}
		];
	}

}
