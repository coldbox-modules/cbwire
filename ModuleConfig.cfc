component {

	this.name               = "cbwire";
	this.version            = "1.0.0";
	this.author             = "";
	this.webUrl             = "https://github.com/coldbox-modules/cbwire";
	this.dependencies       = [];
	this.entryPoint         = "livewire";
	this.layoutParentLookup = false;
	this.viewParentLookup   = false;
	this.cfmapping          = "cbwire";
	this.modelNamespace		= "cbwire";
	this.applicationHelper  = [ "helpers/helpers.cfm" ];

    function configure() {

		settings = {};

		routes = [
            { pattern = "message/:wireComponent", handler = "Main" }
        ];
    }

}
