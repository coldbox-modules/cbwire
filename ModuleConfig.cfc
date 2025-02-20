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
            "autoInjectAssets": true,
            /**
             * Capture our module root for use throughout CBWIRE.
             */
            "moduleRootPath": getCanonicalPath( getCurrentTemplatePath().replaceNoCase( "/ModuleConfig.cfc", "", "one" ) ),
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
            "progressBarColor": "##2299dd"
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
            customInterceptionPoints : []
        };
    }

    /**
     * Returns Livewire's manifest as a struct.
     */
    function getLivewireManifest(){
        var path = getCanonicalPath( variables.modulePath & "/includes/js/manifest.json" );
        return deserializeJSON( fileRead( path ) );
    }

}
