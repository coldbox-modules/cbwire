component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "ComponentEngineSpec.cfc", function(){
			beforeEach( function( currentSpec ){
				setup();
				cbwireRequest = prepareMock( getInstance( "CBWireRequest@cbwire" ) );
				componentObj = prepareMock(
					getInstance( name = "Component@cbwire", initArguments = { "cbwireRequest" : cbwireRequest } )
				);
				variablesScope = componentObj.getInternals();
				structAppend(
					variablesScope,
					{
						"data" : componentObj.getEngine().getDataProperties(),
						"computed" : componentObj.getEngine().getComputedProperties()
					}
				);
				engine = prepareMock(
					getInstance(
						name = "ComponentEngine@cbwire",
						initArguments = {
							wire : componentObj,
							variablesScope : variablesScope
						}
					)
				);
				componentObj.setEngine( engine );
			} );

			describe( "getState()", function(){
				it( "returns the data properties", function(){
					engine.setDataProperties( { "name" : "Grant" } );
					expect( engine.getState().name ).toBe( "Grant" );
				} );
				it( "trims string values if the setting is enabled", function(){
					engine.setSettings( { "trimStringValues" : true } );
					engine.setDataProperties( { "name" : "Grant     " } );
					expect( engine.getState().name ).toBe( "Grant" );
				} );
			} );

			describe( "renderIt()", function(){
				it( "can render", function(){
					engine.renderIt();
					expect( engine.renderIt() ).toInclude( "Component" );
				} );

				it( "renders args._id", function(){
					engine.renderIt();
					expect( engine.renderIt() ).toInclude( engine.getId() );
				} );

				it( "can render directly from component onRender method", function(){
					componentObj.$( "onRender", "<div>some rendering</div>" );
					expect( engine.renderIt() ).toInclude( "some rendering" );
				} );
			} );

			fdescribe( "renderComputedProperties", function(){
				it( "useComputedPropertiesProxy defaults to true", function(){
					expect( engine.getSettings().useComputedPropertiesProxy ).toBeTrue();
				} );

				it( "renders the computed properties immediately by default", function(){
					engine.setComputedProperties( {
						"name" : function(){
							return "Grant"
						}
					} );

					engine.renderComputedProperties();

					expect( engine.getComputedProperties().name() ).toBe( "Grant" );
				} );

				it( "returns functions instead when using computed properties proxy", function(){
					engine.setSettings( { "useComputedPropertiesProxy" : true } );

					engine.setComputedProperties( {
						"name" : function(){
							return "Grant"
						}
					} );

					expect( engine.getComputedProperties().name() ).toBe( "Grant" );
				} );
			} );
		} );
	}

}
