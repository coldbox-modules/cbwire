component {

	this.name = "cbwire";
	this.version = "1.0.0";
	this.author = "";
	this.webUrl = "https://github.com/coldbox-modules/cbwire";
	this.dependencies = [];
	this.entryPoint = "cbwire";
	this.layoutParentLookup = false;
	this.viewParentLookup = false;
	this.cfmapping = "cbwire";
	this.modelNamespace = "cbwire";
	this.applicationHelper = [ "helpers/helpers.cfm" ];

	function configure(){
		settings = {
			/**
			 * Set to true to automatically include CSS and JS 
			 * assets for CBWIRE. This makes it where you do not
			 * need to add wireStyles() and wireScripts() to your layout.
			 */
			"autoInjectAssets": false,
			/**
			 * Capture our module root for use throughout CBWIRE.
			 */
			"moduleRootPath": getCurrentTemplatePath().replaceNoCase( "/ModuleConfig.cfc", "", "one" ),
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
			 * Determines if Turbo should be enabled
			 */
			"enableTurbo" : false,
			/**
			 * Caching for single-file components to speed up response time.
			 * Should be false for local development.
			 */
			"cacheSingleFileComponents": false,
			/**
			 * Trims string properties if set to true
			 */
			"trimStringValues" : false
		};

		routes = [
			{
				"pattern" : "preview-file/:uploadUUID",
				"handler" : "Main",
				"action" : "previewFile"
			},
			{
				"pattern" : "upload-file",
				"handler" : "Main",
				"action" : "uploadFile"
			},
			{
				"pattern" : "update",
				"handler" : "Main",
				"action": "index"
			}
		];

		interceptorSettings = {
			customInterceptionPoints : [
				"onCBWireMount",
				"onCBWireSubsequentRenderIt"
			]
		};

		interceptors = [
			// Init
			{ class : "#moduleMapping#.interceptors.Reinit" },
			// Security
			{ class : "#moduleMapping#.interceptors.hydrate.CheckIncomingRequestHeaders" },
			// Mounting
			{ class : "#moduleMapping#.interceptors.ComponentMounting" },
			// Rendering
			{ class : "#moduleMapping#.interceptors.SubsequentComponentRendering" },
			{ class : "#moduleMapping#.interceptors.AutoInjectAssets" },
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
