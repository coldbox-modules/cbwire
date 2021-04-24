component {

	this.name               = "cbLivewire";
	this.version            = "1.0.0";
	this.author             = "";
	this.webUrl             = "https://github.com/coldbox-modules/cbLivewire";
	this.dependencies       = [];
	this.entryPoint         = "livewire";
	this.layoutParentLookup = false;
	this.viewParentLookup   = false;
	this.cfmapping          = "cbLivewire";
	this.modelNamespace		= "cbLivewire";
	this.applicationHelper  = [ "helpers/helpers.cfm" ];

    function configure() {
        routes = [
            { pattern = "message/:livewireComponent", handler = "Main" }
        ];
    }

}
