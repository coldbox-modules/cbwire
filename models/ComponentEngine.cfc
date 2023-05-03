component extends="coldbox.system.FrameworkSupertype" accessors="true" {

	/**
	 * Inject ColdBox, needed by FrameworkSuperType
	 */
	property name="controller" inject="coldbox";

	/**
	 * The CBWIRE component
	 */
	property name="wire";

	/**
	 * The component's variables scope
	 */
	property name="variablesScope";

	/**
	 * Holds the component's state values before hydration occurs.
	 * Used to compare what's changed and perform dirty tracking
	 */
	property name="beforeHydrationState";

	/**
	 * Determines if component should be rendered or not.
	 */
	property name="noRendering" default="false";

	/**
	 * The default data struct for cbwire components.
	 * This should be overidden in the child component
	 * with data properties.
	 */
	property name="dataProperties";

	/**
	 * The default computed struct for cbwire components.
	 * This should be overidden in the child component with
	 * computed properties.
	 */
	property name="computedProperties";

	/**
	 * Tracks any emitted events during a request lifecycle
	 */
	property name="emittedEvents";

	/**
	 * Holds component metadata.
	 */
	property name="meta";

	/**
	 * Hold finish upload state
	 */
	property name="finishUpload" default="false";

	/**
	 * Hold dirty properties
	 */
	property name="dirtyProperties";


	/**
	 * A beautiful constructor
	 */
	function init( required wire, required variablesScope ){
		setWire( arguments.wire );
		setVariablesScope( arguments.variablesScope );
		setBeforeHydrationState( {} );
		setDataProperties( {} );
		setComputedProperties( {} );
		setEmittedEvents( [] );
		setDirtyProperties( [] );
	}

	/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName String | The method name we are checking.
	 * @return Boolean
	 */
	function hasMethod( required methodName ){
		return structKeyExists( getWire(), arguments.methodName );
	}

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function hydrate(){
		getWire().set_IsInitialRendering( false );
		announce( "onCBWireHydrate", { component : getWire() } );
		return this;
	}

	/**
	 * Apply cbwire attribute to the outer element in the provided rendering.
	 *
	 * @rendering String | The view rendering.
	 */
	function applyWiringToOuterElement( required rendering ){
		var renderingResult = "";

		// Provide a hash of our rendering which is used by Livewire JS.
		var renderingHash = hash( arguments.rendering );

		// Determine our outer element.
		var outerElement = getWire()._getOuterElement( arguments.rendering );

		// Add properties to top element to make cbwire actually work.
		if ( getWire().get_IsInitialRendering() ) {
			// Initial rendering
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#getWire().get_id()#"" wire:initial-data=""#serializeJSON( getWire()._getInitialData( rendering ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
			renderingResult &= "#chr( 10 )#<!-- Livewire Component wire-end:#getWire().get_id()# -->";
		} else {
			// Subsequent renderings
			renderingResult = rendering.replaceNoCase( outerElement, outerElement & " wire:id=""#getWire().get_id()#""", "once" );
		}


		return renderingResult;
	}

	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function renderIt(){
		var cbwireComponent = getWire();
		return cbwireComponent.view( view = cbwireComponent.getTemplatePath() );
	}

	/**
	 * Invokes renderIt() on the cbwire component and caches the rendered
	 * results into variables.rendering.
	 *
	 * @return String
	 */
	function subsequentRenderIt(){
		announce( "onCBWireSubsequentRenderIt", { component : getWire() } );
		return this;
	}

	/**
	 * Render out our component's view
	 *
	 * @view The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module The module to render the view from explicitly
	 * @cache Cached the view output or not, defaults to false
	 * @cacheTimeout The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this view rendering
	 * @cacheProvider The provider to cache this view in, defaults to 'template'
	 * @collection A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow The start row to limit the collection rendering with
	 * @collectionMaxRows The max rows to iterate over the collection rendering with
	 * @collectionDelim  A string to delimit the collection renderings by
	 * @prePostExempt If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
	 *
	 * @return The rendered view
	 */
	function view(
		view = "",
		struct args = {},
		module = "",
		boolean cache = false,
		cacheTimeout = "",
		cacheLastAccessTimeout = "",
		cacheSuffix = "",
		cacheProvider = "template",
		collection,
		collectionAs = "",
		numeric collectionStartRow = "1",
		numeric collectionMaxRows = 0,
		collectionDelim = "",
		boolean prePostExempt = false,
		name
	){
		// Pass the properties of the cbwire component as variables to the view
		arguments.args = getWire()._getState( includeComputed = true );

		// If there are any rendering overrides ( like during file upload ), then merge those in
		structAppend( arguments.args, getWire()._getRenderingOverrides(), true );

		// Provide validation results, either validation results we captured from our action or run them now.
		arguments.args[ "validation" ] = isNull( getWire().getValidationResult() ) ? getWire().validate() : getWire().getValidationResult();

		// Include a reference to the component's id
		arguments.args[ "_id" ] = getWire().get_id();

		/*
			Store our latest rendered id in the request scope so that it can be
			read by the entangle() method.
		*/
		getWire().getCBWireRequest().getEvent().setPrivateValue( "cbwire_lastest_rendered_id", getWire().get_id() );

		arguments.args[ "computed" ] = getComputedProperties();

		if ( structKeyExists( getWire(), "onRender" ) ) {
			// Render custom onRender method
			var result = getWire().onRender( args = arguments.args );
		} else {
			if ( structKeyExists( getWire(), "template" ) ) {
				arguments.view = getWire().template;
			}
			// Render our view using coldbox rendering
			var result = super.renderView( argumentCollection = arguments );
		}

		return result;
	}

	function addDirtyProperty( property ) {
		variables.dirtyProperties.append( arguments.property );
	}

}
