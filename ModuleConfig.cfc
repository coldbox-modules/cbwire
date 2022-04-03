component {

	this.name = "cbwire";
	this.version = "1.0.0";
	this.author = "";
	this.webUrl = "https://github.com/coldbox-modules/cbwire";
	this.dependencies = [];

	/**
	 * This entry point remain as "livewire" as the underlining
	 * Livewire JS library has a hard dependency on this endpoint.
	 */
	this.entryPoint = "livewire";

	this.layoutParentLookup = false;
	this.viewParentLookup = false;
	this.cfmapping = "cbwire";
	this.modelNamespace = "cbwire";
	this.applicationHelper = [ "helpers/helpers.cfm" ];

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
			"componentLocation" : "wires",
			/**
			 * Cache Livewire's manifest for the livewire.js path
			 * with it's hashing as a setting that we can use elsewhere.
			 */
			"manifest" : getLivewireManifest()
		};

		routes = [
			{
				"pattern" : "message/:wireComponent",
				"handler" : "Main",
				"action" : "index"
			},
			{
				"pattern" : "upload-file",
				"handler" : "Main",
				"action" : "uploadFile"
			}
		];

		interceptorSettings = {
			customInterceptionPoints : [
				"onCBWireSubsequentRequest",
				"onCBWireMount",
				"onCBWireHydrate",
				"onCBWireRenderIt",
				"onCBWireSubsequentRenderIt",
				"onCBWireFileUpload"
			]
		};

		interceptors = [
			// Request
			{ class : "#moduleMapping#.interceptors.ProcessIncomingXHRRequest" },
			// Security
			{ class : "#moduleMapping#.interceptors.hydrate.CheckIncomingRequestHeaders" },
			// File upload
			{ class : "#moduleMapping#.interceptors.FileUpload" },
			// Mounting
			{ class : "#moduleMapping#.interceptors.ComponentMounting" },
			{ class : "#moduleMapping#.interceptors.ComponentHydrating" },
			// Rendering
			{ class : "#moduleMapping#.interceptors.InitialComponentRendering" },
			{ class : "#moduleMapping#.interceptors.SubsequentComponentRendering" },
			// Output
			{ class : "#moduleMapping#.interceptors.DisableBrowserCaching" }
		];
	}

	/**
	 * Returns Livewire's manifest as a struct.
	 */
	function getLivewireManifest(){
		var path = getCanonicalPath( variables.modulePath & "/includes/js/manifest.json" );
		return deserializeJSON( fileRead( path ) );
	}

}
