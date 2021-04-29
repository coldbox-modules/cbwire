component extends="cbLivewire.models.Component" accessors="true" {

	property name="message" default="Hello World";

	function renderIt(){
		return renderView( "_cblivewire/helloWorldWithRenderViewPropertyAndArgs" );
	}

}
