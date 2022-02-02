component {

    function onCBWireRenderIt( required event, required data ){

        // if ( structKeyExists( variables, "view" ) && isValid( "string", variables.view ) && len( variables.view ) ) {
		// 	return view( variables.view );
		// }

        var cbwireComponent = data.component;

		var componentName = lCase( getMetadata( cbwireComponent ).name );

        var result = cbwireComponent.view( "wires/#listLast( componentName, "." )#" );

        event.setValue( "_cbwire_rendering", result );
    }

}