component {

    function onCBWireSubsequentRenderIt( event, data ){

        var component = data.component;

		var result = "";

		if ( !component.getNoRendering() ) {
			var result = component.renderIt();
		}


		// Determine children from render
		// var childrenRegexResult = reFindNoCase(
		// 	"<!-- Livewire Component wire-end:(\w+) -->",
		// 	result,
		// 	1,
		// 	true
		// );

		// variables.$children = childrenRegexResult.match.reduce( function( agg, regexMatch ){
		// 	if ( !len( regexMatch ) == 21 || regexMatch == variables.id ) {
		// 		return agg;
		// 	}

		// 	agg[ regexMatch ] = { "id" : "", "tag" : "div" }
		// 	return agg;
		// }, {} );


        event.setValue( "_cbwire_subsequent_rendering", result );
	}
}