component {
    this.name = "cbwire";
    this.version = "@build.version@+@build.number@";
    this.author = "Ortus Solutions";
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
            "autoInjectAssets": true,
            /**
             * Capture our module root for use throughout CBWIRE.
             */
            "moduleRootPath": getCanonicalPath( getCurrentTemplatePath().replaceNoCase( "/ModuleConfig.cfc", "", "one" ) ),
            /**
             * The default storage path for file uploads.
             * Uses the system temporary directory for security.
             */
            "uploadsStoragePath": getCanonicalPath( getTempDirectory() & "/cbwire" ),
            /**
             * The default storage path for single-file component compilation.
             * This must be in the module directory for WireBox to instantiate components.
             */
            "storagePath": getCanonicalPath( getCurrentTemplatePath().replaceNoCase( "/ModuleConfig.cfc", "", "one" ) & "/models/tmp" ),
            /**
             * The URL to the module root. The sometimes needs to be overridden for certain server configurations.
             */
            "moduleRootURL": "/modules/cbwire",
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
            "wiresLocation" : "wires",
            /**
             * Trims string properties if set to true
             */
            "trimStringValues" : false,
            /**
             * Enables or disables the progress bar when using wire:navigate
             */
            "showProgressBar": true,
            /**
             * The color of the progress bar when using wire:navigate
             */
            "progressBarColor": "##2299dd",
            /**
             * Enables or disables checksum validation for component payloads.
             * We recommend always leaving this enabled, but you can disable it
             * as needed.
             */
            "checksumValidation": true
        };

        routes = [
            {
                "pattern" : "preview-file/:uploadUUID",
                "handler" : "Main",
                "action" : "previewFile"
            },
            {
                "pattern" : "upload",
                "handler" : "Main",
                "action" : "uploadFile"
            },
            {
                "pattern" : "update",
                "handler" : "Main",
                "action": "index"
            }
        ];

        interceptors = [
            // Init
            { class : "#moduleMapping#.interceptors.CBWIRE" }
        ];

        interceptorSettings = {
            customInterceptionPoints : [
				"onCBWIREMount",
				"preCBWIRERender",
				"onCBWIRERender",
				"preCBWIREUpdate",
				"onCBWIREUpdate",
				"onCBWIRESecureFail"
			]
        };
    }

}
