component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();
        // delete any files in models/tmp folder
        local.tempFolder = expandPath( "../../../models/tmp" );
        if ( directoryExists( local.tempFolder ) ) {
            directoryDelete( local.tempFolder, true );
        }
        directoryCreate( local.tempFolder );
    }

    // Lifecycle methods and BDD suites as before...
    function run(testResults, testBox) {

        describe( "Layout", function() {

            beforeEach( function(){
                setup();
            } );

            it( "should auto inject assets", function() {
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                settings.autoInjectAssets = true;
                var event = this.get( "main.index" );
                var html = event.getRenderedContent();
                expect( html ).toInclude( "<!-- CBWIRE Styles -->" );
                expect( html ).toInclude( "<!-- CBWIRE Scripts -->" );
                expect( reMatchNoCase( "CBWIRE Styles", html ).len() ).toBe( 1 );
                expect( reMatchNoCase( "CBWIRE Scripts", html ).len() ).toBe( 1 );
            } );

            it( "should not auto inject assets", function() {
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                settings.autoInjectAssets = false;
                var event = this.get( "main.index" );
                var html = event.getRenderedContent();
                expect( html ).notToInclude( "<!-- CBWIRE Styles -->" );
                expect( html ).notToInclude( "<!-- CBWIRE Scripts -->" );
                expect( reMatchNoCase( "CBWIRE Styles", html ).len() ).toBe( 0 );
                expect( reMatchNoCase( "CBWIRE Scripts", html ).len() ).toBe( 0 );
            } );

            it( "should use default display bar color", function() {
                var CBWIREController = getInstance( "CBWIREController@cbwire" );
                var html = CBWIREController.getStyles( cache=false );
                expect( html ).toInclude( "--livewire-progress-bar-color: ##2299dd;" );
            } );

            it( "should be able to change the display bar color", function() {
                var CBWIREController = getInstance( "CBWIREController@cbwire" );
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                settings.progressBarColor = "##cc0000";
                var html = CBWIREController.getStyles( cache=false );
                expect( html ).toInclude( "--livewire-progress-bar-color: ##cc0000;" );
            } );

            it( "should show the progress bar by default", function() {
                var CBWIREController = getInstance( "CBWIREController@cbwire" );
                var html = CBWIREController.getScripts();
                expect( html ).notToInclude( " data-no-progress-bar " );
            } );

            it( "should be able to disable the progress bar", function() {
                var CBWIREController = getInstance( "CBWIREController@cbwire" );
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                settings.showProgressBar = false;
                var html = CBWIREController.getScripts();
                expect( html ).toInclude( " data-no-progress-bar " );
            } );

            it( "should have default updateEndpoint", function() {
                var CBWIREController = getInstance( "CBWIREController@cbwire" );
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                expect( CBWIREController.getUpdateEndpoint() ).toBe( "/cbwire/update" );
            } );

            it( "should be able to set updateEndpoint", function() {
                var CBWIREController = getInstance( "CBWIREController@cbwire" );
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                settings.updateEndpoint = "/index.cfm/cbwire/update";
                expect( CBWIREController.getUpdateEndpoint() ).toBe( "/index.cfm/cbwire/update" );
            } );

            it( "should have component request assets added in head", function() {
                var event = this.get( "tests.requestassets" );
                var html = event.getRenderedContent();
                var beforeHead = left( html, findNoCase( "</head>", html )-1 );
                expect( beforeHead ).toInclude( "<link rel=""stylesheet"" href=""https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"">" );
            } );

        } );

        describe("Component.cfc", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                testComponent = getInstance("wires.TestComponent");
                testComponent
                    ._withEvent( getRequestContext( ) )
                    ._withPath( "wires.TestComponent" );
                CBWIREController = getInstance( "CBWIREController@cbwire" );
                prepareMock( testComponent );
            });

            it( "should return a rendered component", function () {
                var result = CBWIREController.wire( "test.should_render_a_component" );
                expect( result ).toBeString();
            } );

            it( "should raise error if markers are not found in single-file component", function() {
                expect( function() {
                    var result = CBWIREController.wire( "test.should_raise_error_for_single_file_component" );
                } ).toThrow( type="CBWIREException" );
            } );

            it("should have generated setters available in onMount", function() {
                var result = CBWIREController.wire( "test.should_have_generated_setters_and_getters_available_in_onmount" );
                expect( result ).toInclude( "<p>Name: Jane Doe</p>" );
                expect( result ).toInclude( "<p>Copied name: John Doe</p>" );
            });

            it("should have generated getter available in template", function() {
                var result = CBWIREController.wire( "test.should_have_generated_getter_accessible_in_template" );
                expect( result ).toInclude( "<p>Name: John</p>" );
                expect( result ).toInclude( "<p>Age: 30</p>" );
                expect( result ).toInclude( "<p>City: New York</p>" );
            });

            it( "should be able to call getInstance from template and component", function() {
                var result = CBWIREController.wire( "test.should_be_able_to_call_getInstance_from_template_and_component" );
                expect( result ).toInclude( "<p>OnMount Result: 3</p>" );
                expect( result ).toInclude( "<p>Inline Result: 5</p>" );
            } );

            it( "should provide _id variable to template", function() {
                var result = CBWIREController.wire( "test.should_provide_id_variable_to_template" );
                expect( reFindNoCase( "<p>Component ID: [A-Za-z0-9]+</p>", result ) ).toBeGT( 0 );
            } );

            it( "should support rendering wires with x-data and arrow functions", function() {
                var result = CBWIREController.wire( "test.should_support_rendering_wires_with_xdata_and_arrow_functions" );
                expect( reFindNoCase( "<div wire:snapshot=""\{(.*)\}"" wire:effects=""(\[\])"" wire:id=""([A-Za-z0-9]+)"" x-data=""{", result ) ).toBeGT( 0 );
            } );

            it("should be able to call UDF/action from template", function() {
                var result = CBWIREController.wire( "test.should_be_able_to_call_udf_from_template" );
                expect( result ).toInclude( "<p>Result: 3</p>" );
            } );

            it( "should render with correct snapshot, effects, and id attribute", function() {
                var result = CBWIREController.wire( "test.should_render_with_correct_snapshot_effects_and_id_attribute" );
                var parsing = parseRendering( result );
                expect( parsing.outerElement ).toBe( "div" );
                expect( reFindNoCase( "^[A-Za-z0-9]+$", parsing.snapshot.memo.id ) ).toBeGT( 0 );
                expect( parsing.snapshot.data.name ).toBe( "Jane Doe" );
                expect( parsing.effects ).toBeArray();
                expect( parsing.effects.len() ).toBe( 0 );
            } );

            it("should render string booleans as booleans", function() {
                var result = CBWIREController.wire( "test.should_render_string_booleans_as_booleans" );
                var parsing = parseRendering( result );
                expect( isBoolean( parsing.snapshot.data.stringBooleanValue ) ).toBeTrue();
                expect( parsing.snapshot.data.stringBooleanValue ).toBeTrue();
            });

            it( "should render with a onRender method", function() {
                var result = CBWIREController.wire( "test.should_render_with_a_onRender_method" );
                expect( result ).toInclude( "<p>I rendered from onRender</p>" );
            } );

            it( "should render with renderIt for backwards compatibility", function() {
                var result = CBWIREController.wire( "test.should_render_with_renderIt_for_backwards_compatibility" );
                expect( result ).toInclude( "I rendered from renderIt" );
            } );

            it("should implicitly render a view template", function() {
                var result = CBWIREController.wire( "test.should_implicitly_render_a_view_template" );
                expect( result ).toInclude( "<p>Implicitly rendered</p>" );
            } );

            it( "should support passing params into a onRender method", function() {
                var result = CBWIREController.wire( "test.should_support_passing_params_into_a_onRender_method" );
                expect( result ).toInclude( "<p>Passed in: 5</p>" );
            } );

            it( "should support computed properties", function() {
                var result = CBWIREController.wire( "test.should_support_computed_properties" );
                expect( reFindNoCase( "UUID: [A-Za-z0-9-]+", result ) ).toBeGT( 0 );
            } );

            it( "should cache computed properties", function() {
                var result = CBWIREController.wire( "test.should_cache_computed_properties" );
                var firstUUID = reFindNoCase( "UUID: ([A-Za-z0-9-]+)", result, 1, true ).match[ 2 ];
                expect( result ).toInclude( "<p>UUID: #firstUUID#</p>" );
                expect( result ).toInclude( "<p>UUID2: #firstUUID#</p>" );
            } );

            it( "should accept false flag for computed properties to prevent caching", function() {
                var result = CBWIREController.wire( "test.should_accept_false_flag_for_computed_properties_to_prevent_caching" );
                var firstUUID = reFindNoCase( "UUID: ([A-Za-z0-9-]+)", result, 1, true ).match[ 2 ];
                expect( result ).toInclude( "<p>UUID: #firstUUID#</p>" );
                expect( result ).notToInclude( "<p>UUID2: #firstUUID#</p>" );
            } );

            it( "should support accessing data properties using legacy 'args' scope", function() {
                var result = CBWIREController.wire( "test.should_support_accessing_data_properties_using_legacy_args_scope" );
                expect( result ).toInclude( "<p>Name: Jane Doe</p>" );
            } );

            it( "should support onBoot() firing when the component is initially rendered", function() {
                var result = CBWIREController.wire( "test.should_support_onBoot_firing_when_the_component_is_initially_rendered" );
                expect( result ).toInclude( "<p>OnBoot Fired</p>" );
            } );

            it( "should be able to call inherited methods from template", function() {
                var result = CBWIREController.wire( "test.should_be_able_to_call_inherited_methods_from_template" );
                expect( result ).toInclude( "<p>Result: Hello World!</p>" );
            } );

            xit( "should support deep nesting with correct count of children", function() {
                var result = CBWIREController.wire( "test.should_support_deep_nesting" );
                var parent = parseRendering( result, 1 );
                writeDump( result );
                writeDump( parent );
                abort;
                var child1 = parseRendering( result, 2 );
                var child2 = parseRendering( result, 3 );
                expect( parent.snapshot.memo.children.count() ).toBe( 2 );
                expect( child1.snapshot.memo.children.count() ).toBe( 1 );
                expect( child2.snapshot.memo.children.len() ).toBe( 0 );
            } );

            it( "shouldn't isolate by default", function() {
                var result = CBWIREController.wire( "test.shouldnt_isolate_by_default" );
                expect( result ).toInclude( "&quot;isolate&quot;:false" );
            } );

            it( "should isolate when using isolate=true", function() {
                var result = CBWIREController.wire( "test.should_isolate_when_using_isolate_true" );
                expect( result ).toInclude( "&quot;isolate&quot;:true" );
            } );

            it( "should isolate when using lazyLoad=true", function() {
                var result = CBWIREController.wire( "test.should_isolate_when_using_lazyLoad_true" );
                expect( result ).toInclude( "&quot;isolate&quot;:true" );
            } );

            it( "should support hasErrors(), hasError( prop ), and getError( prop ) for validation", function() {
                var result = CBWIREController.wire( "test.should_support_hasErrors_hasError_getError_for_validation" );
                expect( result ).toInclude( "<p>Has errors: true</p>" );
                expect( result ).toInclude( "<p>Has error: true</p>" );
                expect( result ).toInclude( "<p>Get errors length: 1</p>" );
                expect( result ).toInclude( "<p>Error: The 'name' field is required</p>" );
            } );

            xit( "should display component errors in a CBWIRE custom exception page", function() {
                var result = CBWIREController.wire( "test.should_display_component_errors_in_a_CBWIRE_custom_exception_page" );
            } );

            it( "should be able to render coldbox views using view() from a template", function() {
                var result = CBWIREController.wire( "test.should_be_able_to_render_coldbox_views_using_view_from_a_template" );
                expect( result ).toInclude( "<p>Rendered using view()!</p>" );
            } );

            it( "should be able to render coldbox views using view() from a component", function() {
                var result = CBWIREController.wire( "test.should_be_able_to_render_coldbox_views_using_view_from_a_component" );
                expect( result ).toInclude( "<p>Rendered from component!</p>" );
            } );

            xit( "should throw an error if we try to set a data property that doesn't exist", function() {
                expect(function() {
                    testComponent.setInvalidProperty("value");
                }).toThrow(type="CBWIREException");
            });

            xit( "should reset all data properties", function() {
                testComponent.addModule( "ContentBox" );
                testComponent.reset();
                expect( testComponent.numberOfModules() ).toBe( 0 );
            } );

            xit( "should reset a single data property", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.reset( "modules" );
                expect( testComponent.numberOfModules() ).toBe( 0 );
                expect( testComponent.numberOfFrameworks() ).toBe( 1 );
            } );

            xit( "should reset multiple data properties", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.reset( [ "modules", "frameworks" ] );
                expect( testComponent.numberOfModules() ).toBe( 0 );
                expect( testComponent.numberOfFrameworks() ).toBe( 0 );
            } );

            xit( "should resetExcept a single data property", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.resetExcept( "modules" );
                expect( testComponent.numberOfModules() ).toBe( 1 );
                expect( testComponent.numberOfFrameworks() ).toBe( 0 );
            } );

            xit( "should resetExcept multiple data properties", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.resetExcept( [ "modules" ] );
                expect( testComponent.numberOfModules() ).toBe( 1 );
                expect( testComponent.numberOfFrameworks() ).toBe( 0 );
            } );

            it( "should support child components", function() {
                var result = CBWIREController.wire( "test.should_support_child_components" );
                var parent = parseRendering( result, 1 );
                var child = parseRendering( result, 2 );
                expect( result ).toInclude( "<p>Main component" );
                expect( result ).toInclude( "<p>Child component</p>" );
            } );

            it( "should return proper names with child components", function() {
                var result = CBWIREController.wire( "test.should_support_child_components" );
                var parent = parseRendering( result, 1 );
                var child = parseRendering( result, 2 );
                expect( parent.snapshot.memo.name ).toBe( "should_support_child_components" );
                expect( child.snapshot.memo.name ).toBe( "child_component" );
                expect( parent.snapshot.memo.children ).toBeStruct();
            } );

            it( "should track child components", function() {
                var result = CBWIREController.wire( "test.should_support_child_components" );
                var parent = parseRendering( result, 1 );
                var child = parseRendering( result, 2 );
                expect( parent.snapshot.memo.children).toBeStruct();
                expect( structCount( parent.snapshot.memo.children ) ).toBe( 1 );
                var keys = structKeyArray( parent.snapshot.memo.children );
                expect( parent.snapshot.memo.children[ keys[ 1 ] ] ).toBeArray();
                expect( parent.snapshot.memo.children[ keys[ 1 ] ][ 1 ] ).toBe( "div" );
                expect( parent.snapshot.memo.children[ keys[ 1 ] ][ 2 ] ).toBe( child.snapshot.memo.id );
            } );

            it( "should not render cbwire:script tags", function() {
                var result = CBWIREController.wire( "test.should_not_render_cbwire_script_tags" );
                expect( result ).notToInclude( "<cbwire:script>" );
                expect( result ).notToInclude( "</cbwire:script>" );
            } );

            it( "should not render cbwire:assets tags", function() {
                var result = CBWIREController.wire( "test.should_not_render_cbwire_assets_tags" );
                expect( result ).notToInclude( "<cbwire:assets>" );
                expect( result ).notToInclude( "</cbwire:assets>" );
                expect( result ).notToInclude( "tailwind.min.css" );
            } );

            it( "should track assets in snapshot memo", function() {
                var result = CBWIREController.wire( "test.should_track_assets_in_snapshot_memo" );
                var parsing = parseRendering( result );
                expect( parsing.snapshot.memo.assets ).toBeArray();
                expect( parsing.snapshot.memo.assets.len() ).toBe( 1 );
            } );

            it( "should not track assets in snapshot memo when lazy loaded", function() {
                var result = CBWIREController.wire( name="test.should_track_assets_in_snapshot_memo", lazy=true );
                var parsing = parseRendering( result );
                expect( parsing.snapshot.memo.assets ).toBeArray();
                expect( parsing.snapshot.memo.assets.len() ).toBe( 0 );
            } );

            it( "should track scripts in snapshot memo", function() {
                var result = CBWIREController.wire( "test.should_track_scripts_in_snapshot_memo" );
                var parsing = parseRendering( result );
                expect( parsing.snapshot.memo.scripts ).toBeArray();
                expect( parsing.snapshot.memo.scripts.len() ).toBe( 2 );
            } );

            xit( "should provide original path to component when there is a template rendering error", function() {
                var result = CBWIREController.wire( "test.should_raise_error_for_template_rendering_error" );
                expect( function() {
                } ).toThrow( type="CBWIREException", message="Error rendering template: test.should_raise_error_for_template_rendering_error" );
            } );

            it( "should validate()", function() {
                var result = testComponent.validate();
                expect( result ).toBeInstanceOf( "ValidationResult" );
                expect( result.hasErrors() ).toBeTrue();
            } );

            it("should access validation from view", function() {
                var result = testComponent.validate();
                var viewContent = testComponent.template("wires.superheroesvalidation");
                expect(viewContent).toInclude("The 'mailingList' has an invalid type, expected type is email");
            });

            it( "should auto validate", function() {
                var viewContent = testComponent.template("wires.superheroesvalidation");
                expect(viewContent).toInclude("The 'mailingList' has an invalid type, expected type is email");
            } );

            it( "should thrown exception for validateOrFail()", function() {
                expect(function() {
                    testComponent.validateOrFail(
                        target = { "module": "" },
                        constraints = { "module": { "required": true } }
                    );
                }).toThrow( type="ValidationException" );
            } );

            xit( "should pass validation with validateOrFail()", function() {
                var result = testComponent.validateOrFail(
                    target = { "module": "CBWIRE" },
                    constraints = { "module": { "required": true } }
                );
                expect( result ).toBeInstanceOf( "ValidationResult" );
                expect( result.getAllErrors().len() ).toBe( 0 );
            } );

            it( "should hasError( field)", function() {
                testComponent.validate();
                expect( testComponent.hasErrors( "mailingList" ) ).toBeTrue();
            } );

            it( "should entangle", function() {
                var result = testComponent.entangle( "mailingList" );
                expect( result ).toInclude( "window.Livewire.find" );
                expect( result ).toInclude( "entangle( 'mailingList' )");
            } );

            it( "should reference application helper methods", function() {
                var result = testComponent.template( "wires.testcomponentwithhelpermethods" );
                expect( result ).toInclude( "someGlobalUDF: yay!" );
            } );

            it("should throw an exception for a non-existent view", function() {
                expect(function() {
                    testComponent.template("nonExistentView");
                }).toThrow();
            });

            xit("should throw an error for HTML without a single outer element", function() {
                expect(function() {
                    testComponent._render( testComponent.template( "wires.testing.multipleouterelements" ) );
                }).toThrow("Template has more than one outer element, or is missing an end tag </element>.");
            });

            it("should render complex HTML structures", function() {
                testComponent._render( testComponent.template( "wires.testing.complexhtml" ) );
            } );

            it( "should include listeners within wire:effects on initial render", function() {
                var result = testComponent._render( testComponent.template( "wires.TestComponent" ) );
                expect( result ).toInclude( "wire:effects=""{&quot;listeners&quot;:[&quot;someEvent&quot;]}""" );
            } );

            it( "should support single file components", function() {
                var cbwireController = getInstance("CBWIREController@cbwire");
                var result = cbwireController.wire( "wires.TestSingleFileComponent" );
                expect( result ).toInclude( "<div wire:snapshot" );
            } );

            xit( "should throw error if a listener is defined but the method does not exist", function() {
                try {
                    var result = getInstance( "wires.TestComponentWithInvalidListener" );
                } catch ( CBWIREException e ) {
                    expect( e.message ).toBe( "The listener 'someEvent' references a method 'someMethod' but this method does not exist. Please implement 'someMethod()' on your component." );
                }
            } );

        });

        describe("Incoming Requests", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                cbwireController = getInstance("CBWIREController@cbwire");
                event = getRequestContext();
                prepareMock( cbwireController );
            });

            it( "should trim string values if global setting enabled on coldbox.cfc", () => {
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                settings.trimStringValues = true;
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_trim_string_values_if_global_setting_enabled",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "name": "Jane Doe "
                    },
                    calls = [],
                    updates = {
                        "name": " Jane Doe "
                    }
                );
                var result = cbwireController.handleRequest( payload, event );
                expect( result.components.first().effects.html ).toInclude( "<p>Name: Jane Doe</p>" );
                settings.trimStringValues = false;
            } );

            it( "should trim string values if enabled on component", () => {
                var settings = getInstance( "coldbox:modulesettings:cbwire" );
                settings.trimStringValues = false;
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_trim_string_values_if_enabled_on_component",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "name": "Jane Doe "
                    },
                    calls = [],
                    updates = {
                        "name": " Jane Doe "
                    }
                );
                var result = cbwireController.handleRequest( payload, event );
                expect( result.components.first().effects.html ).toInclude( "<p>Name: Jane Doe</p>" );
                settings.trimStringValues = false;
            } );

            it( "should track cbwire:assets in http response", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_track_cbwire_assets_in_http_response",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = {}
                );
                var result = cbwireController.handleRequest( payload, event );
                expect( isStruct( result.assets ) );
                expect( result.assets.count() ).toBe( 1 );
                var keys = result.assets.keyArray();
                expect( result.assets[ keys.first() ] ).toInclude( "tailwind.min.css" );
            } );

            it( "it should NOT return assets if they were already rendered", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_track_cbwire_assets_in_http_response",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": [],
                        "assets": [ "FC8550AF548BA7D81CAA8C2333141FDA" ]
                    },
                    data = {},
                    calls = [],
                    updates = {}
                );
                var result = cbwireController.handleRequest( payload, event );
                expect( isArray( result.assets ) ).toBeTrue();
                expect( result.assets.len() ).toBe( 0 );
            } );

            it( "should support $refresh action", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_support_refresh_action",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "$refresh",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var result = cbwireController.handleRequest( payload, event );
                var html = result.components.first().effects.html;
                expect( reFindNoCase( "<p>Refreshed at [0-9]+</p>", html ) ).toBeGT( 0 );
            } );

            it( "should support rendering wires with x-data and arrow functions", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_support_rendering_wires_with_xdata_and_arrow_functions",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = {}
                );
                var result = cbwireController.handleRequest( payload, event );
                expect( reFindNoCase( "<div wire:id=""([A-Za-z0-9]+)"" x-data=""{", result.components.first().effects.html ) ).toBeGT( 0 );
            } );

            it( "should throw a 419 Page Expired error if the CSRF token doesn't match", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = {},
                    csrfToken = "badToken"
                );
                expect( function() {
                    cbwireController.handleRequest( payload, event );
                } ).toThrow( type="CBWIREException", message="Page expired." );
            } );

            it( "should provide a handleRequest() method that returns subsequent payloads", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "runActionWithParams",
                            "params": [ "CBWIRE" ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( isStruct( response ) ).toBeTrue();
            } );

            it( "should return the same id", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "runActionWithParams",
                            "params": [ "CBWIRE" ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( deserializeJson( response.components[1].snapshot ).memo.id ).toBe( "Z1Ruz1tGMPXSfw7osBW2" );
            } );

            it( "should run action we pass it", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "changeTitle",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "CBWIRE Slays!" );
            } );

            it( "should run action we pass it with parameters", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "runActionWithParams",
                            "params": [ 'world' ]
                        }
                    ],
                    updates = {}
                );

                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Title: Hello world from CBWIRE!" );
            } );

            it( "should return an outer element with the same id that we passed in", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "Counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "increment",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "id=""Z1Ruz1tGMPXSfw7osBW2""" );
            } );

            it( "should provide updates to data properties", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "title": "CBWIRE Rocks!"
                    },
                    calls = [],
                    updates = {
                        "title": "CBWIRE Slaps!"
                    }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "CBWIRE Slaps!" );
            } );

            it( "should dispatch an event without params", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_dispatch_an_event_without_params",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "dispatchWithoutParams",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "someEvent" );
                expect( response.components[1].effects.dispatches[1].params ).toBeStruct();
                expect( structCount( response.components[1].effects.dispatches[1].params ) ).toBe(0);

            } );

            it( "should dispatch an event with params", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_dispatch_an_event_with_params",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "dispatchWithParams",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "someEvent" );
                expect( response.components[1].effects.dispatches[1].params[ "name" ] ).toBe( "CBWIRE" );
            } );

            it( "should dispatchSelf()", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "runDispatchSelf",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "someEvent" );
                expect( response.components[1].effects.dispatches[1].params[ "name"] ).toBe( "CBWIRE" );
                expect( response.components[1].effects.dispatches[1].self ).toBeTrue();
            } );

            it( "should dispatchTo()", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "runDispatchTo",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "someEvent" );
                expect( response.components[1].effects.dispatches[1].params.hello ).toBe( "world" );
                expect( response.components[1].effects.dispatches[1].to ).toBe( "anotherComponent" );
            } );

            it( "should track child components on the response", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": {
                            "data-binding": [ "div", "dsfsadfasdfsdf" ]
                        }
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "runDispatchSelf",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                var snapshot = deserializeJson( response.components[ 1 ].snapshot );
                expect( snapshot.memo.children.count() ).toBe( 1 );
            } );

            it(" should call onUpdate if it exists", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_call_onupdate",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "cbwireVersion": 3
                    },
                    calls = [],
                    updates = {
                        "cbwireVersion": 4
                    }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "onUpdateCalled: true" );
            } );

            it( "should not call onupdate if no updates are actually passed", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_call_onupdate",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "cbwireVersion": 3
                    },
                    calls = [],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "onUpdateCalled: false" );
            } );

            it( "should call onUpdate[Property] if it exists", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_call_onupdate_property",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "cbwireVersion": 3,
                        "newValue": "",
                        "oldValue": ""
                    },
                    calls = [],
                    updates = {
                        "cbwireVersion": 4
                    }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "CBWIRE Version: 4" );
                expect( response.components[1].effects.html ).toInclude( "New Value: 4" );
                expect( response.components[1].effects.html ).toInclude( "Old Value: 3" );
            } );

            it( "should call onHydrate() if it exists", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_call_onhydrate",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "hydrated": false,
                        "hydratedProperty": false
                    },
                    calls = [],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Hydrated: true" );
            } );

            it( "should call onHydrate[Property] if it exists", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_call_onhydrate",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "hydrated": false,
                        "hydratedProperty": false
                    },
                    calls = [],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Hydrated Property: true" );
            } );

            it( "should be able to return javascript to return", () => {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "runJSMethod",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.xjs ).toBeArray();
                expect( response.components[1].effects.xjs.first() ).toBe( "alert('Hello from CBWIRE!');" );
            } );

            it( "should track return values", () => {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "runActionWithReturnValue",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.returns ).toBeArray();
                expect( response.components[1].effects.returns.first() ).toBe( "Return from CBWIRE!" );
            } );

            it( "should support multi select dropdowns and the incoming array values", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = [
                        "modules.0": "CBWIRE",
                        "modules.1": "CBORM",
                        "modules.2": "__rm__"
                    ]
                );
                var response = cbwireController.handleRequest( payload, event );
                var snapshot = deserializeJson( response.components[ 1 ].snapshot );
                expect( snapshot.data.modules ).toBeArray();
                expect( snapshot.data.modules.len() ).toBe( 2 );
                expect( snapshot.data.modules[ 1 ] ).toBe( "CBWIRE" );
                expect( snapshot.data.modules[ 2 ] ).toBe( "CBORM" );
            } );

            it( "should support firing onBoot on subsequent requests", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_support_onBoot_firing_when_the_component_is_initially_rendered",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "booted": false
                    },
                    calls = [],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "<p>OnBoot fired</p>" );
            } );

            it( "should redirect the user", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_redirect_the_user",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "someMethod",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.redirect ).toBe( "/some-uri" );
                expect( response.components[1].effects.redirectUsingNavigate ).toBeFalse();
            } );

            it( "should redirect the user using navigate = true", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_redirect_the_user_using_navigate",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "someMethod",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.redirect ).toBe( "/some-uri" );
                expect( response.components[1].effects.redirectUsingNavigate ).toBeTrue();
            } );

            it( "should handle array of struct data properties", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_support_array_of_struct_data_properties",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "title": "CBWIRE Rocks!",
                        "states": [
                            { "name" : "Maryland", "abr" : "MD" },
                            { "name" : "Virginia", "abr" : "VA" },
                            { "name" : "Florida", "abr" : "FL" },
                            { "name" : "Wyoming", "abr" : "WY" }
                        ]
                    },
                    calls = [],
                    updates = {
                        "title": "CBWIRE Slaps!"
                    }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "CBWIRE Slaps!" );
            } );

            it( "should throw a CBWIREException when trying to update a locked property (array)", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_throw_exception_on_locked_data_property_array",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = { "lockedPropertyKey" : "Changed Value" }
                );
				expect( function() {
					cbwireController.handleRequest( payload, event );
				} ).toThrow( message="The property lockedPropertyKey is locked and cannot be updated."  );
            } );

            it( "should throw a CBWIREException when trying to update a locked property (list)", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_throw_exception_on_locked_data_property_list",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = { "lockedPropertyKey" : "Changed Value" }
                );
				expect( function() {
					cbwireController.handleRequest( payload, event );
				} ).toThrow( message="The property lockedPropertyKey is locked and cannot be updated."  );
            } );

            it( "should throw a CBWIREException when trying to update a locked property (string)", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_throw_exception_on_locked_data_property_string",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = { "lockedPropertyKey" : "Changed Value" }
                );
				expect( function() {
					cbwireController.handleRequest( payload, event );
				} ).toThrow( message="The property lockedPropertyKey is locked and cannot be updated."  );
            } );

            it( "should not throw an error when empty array is used for locked property ", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_not_throw_exception_on_locked_data_property_empty_array",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = { "lockedPropertyKey" : "Changed Value" }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Locked Property Value: Changed Value" );
            } );

            it( "should not throw an error when empty string is used for locked property ", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_not_throw_exception_on_locked_data_property_empty_string",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = { "lockedPropertyKey" : "Changed Value" }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Locked Property Value: Changed Value" );
            } );

            it( "should not throw an error when data type other than array or string is used for locked property ", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "test.should_not_throw_exception_on_locked_data_property_other",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [],
                    updates = { "lockedPropertyKey" : "Changed Value" }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Locked Property Value: Changed Value" );
            } );

        } );

        describe("File Uploads", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                cbwireController = getInstance("CBWIREController@cbwire");
                event = getRequestContext();
                prepareMock( cbwireController );
            });

            it( "should _startUpload() and return a generated signed URL", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "_startUpload",
                            "params": [
                                "testFile",
                                [ "name": "image.png", "size": 118672, "type": "image/png" ],
                                false
                            ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches[1].name ).toBe( "upload:generatedSignedUrl" );
                expect( response.components[1].effects.dispatches[1].self ).toBeTrue();
                expect( response.components[1].effects.dispatches[1].params.name ).toBe( "testFile" );
                expect( response.components[1].effects.dispatches[1].params.url ).toInclude( "/cbwire/upload" );
                expect( reFindNoCase( "/cbwire/upload\?expires=[0-9]+&signature=[A-Za-z0-9]+$", response.components[1].effects.dispatches[1].params.url ) ).toBeGT( 0 );
            } );

            xit( "should _finishUpload()", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "_finishUpload",
                            "params": [
                                "testFile",
                                [ "/GEnKdSxTGWhp2jG5VyDQLxBW1zq79T-metaaW1hZ2UucG5n-.png" ],
                                false
                            ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
            } );
        } );

        describe("Lazy Loading", function() {
            beforeEach(function(currentSpec) {
                // Setup initializes application environment and mocks dependencies
                setup();
                testComponent = getInstance("wires.TestComponent"); // Assuming TestComponent is a component that supports lazy loading
                testComponent._withEvent(getRequestContext());
                CBWIREController = getInstance( "CBWIREController@cbwire" );
                prepareMock(testComponent);
            });

            it( "should isolate when lazy loading", function() {
                var lazyHtml = testComponent.wire(
                    name="TestComponent",
                    params={},
                    key="",
                    lazy=true
                );
                expect( lazyHtml ).toInclude( "&quot;isolate&quot;:true" );
            } );

            it( "should lazy load a component using the original outer element", function() {
                var lazyHtml = testComponent.wire(
                    name="TestTableRowComponent",
                    params={},
                    key="",
                    lazy=true
                );
                expect( reFindNoCase( "^<tr\s+", lazyHTML.trim() ) ).toBeTrue();
            } );

            it( "It should throw error if lazy component doesn't have a placeholder", function() {
                expect( function() {
                    testComponent.wire(
                        name="TestComponentWithoutPlaceholder",
                        params={},
                        key="",
                        lazy=true
                    );
                } ).toThrow( type="CBWIREException", message="Lazy loaded components must have a placeholder." );
            } );

            it("should return a base64-encoded lazy loading snapshot when wire() is called with lazy=true", function() {
                var lazyHtml = testComponent.wire(
                    name="TestComponent",
                    params={},
                    key="",
                    lazy=true
                );
                // Check if the returned HTML contains a base64-encoded snapshot and lazy load attributes
                expect(lazyHtml).toInclude("x-intersect=");
                expect(lazyHtml).toInclude("wire:snapshot=");
                expect(lazyHtml).toInclude("Test Placeholder");
            });

            it("should not immediately render the component's content when lazy is true", function() {
                var lazyHtml = testComponent.wire(
                    name="TestComponent",
                    params={},
                    key="",
                    lazy=true
                );
                // Check that the actual component content is not included in the output
                expect(lazyHtml).notToInclude("Actual Component Content");
            });

            it( "should detect lazy loaded children", function() {
                var parentHTML = CBWIREController.wire( "test.should_detect_lazy_loaded_children" );
                var childHTML = reMatchNoCase( "<!-- start child -->.*<!-- end child -->", parentHTML )[ 1 ];
                // Remove child HTML from parent HTML
                parentHTML = replaceNoCase( parentHTML, childHTML, "", "one" );
                var parent = parseRendering( parentHTML );
                var child = parseRendering( childHTML );
                // Ensure parent and child ids are different
                expect( parent.snapshot.memo.id ).notToBe( child.snapshot.memo.id );
                // Ensure parent has a child and it's the lazy loaded child
                expect( structCount( parent.snapshot.memo.children ) ).toBe( 1 );
                var keys = structKeyArray( parent.snapshot.memo.children );
                expect( parent.snapshot.memo.children[ keys[ 1 ] ] ).toBeArray();
                expect( parent.snapshot.memo.children[ keys[ 1 ] ][ 1 ] ).toBe( "div" );
                expect( parent.snapshot.memo.children[ keys[ 1 ] ][ 2 ] ).toBe( child.snapshot.memo.id );
            } );
        });

        describe("CBWIREController", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                cbwireController = getInstance("CBWIREController@cbwire");
                prepareMock( cbwireController );
            });

            it( "should return an object", function() {
                expect( isObject( cbwireController ) ).toBeTrue();
            } );

            it( "should provide a wire() method that returns html", function() {
                var html = cbwireController.wire(
                    name="Counter",
                    params={},
                    key=""
                );
                expect( html ).toInclude( "wire:snapshot" );
                expect( html ).toInclude( "wire:effects" );
            } );

            it( "should automatically sets passed params to wire()", function() {
                var html = cbwireController.wire(
                    name="TestComponent",
                    params={ "title": "Override title" }
                );
                expect( html ).toInclude( "Title: Override title" );
            } );

            it( "should pass params to onMount if it exists", function() {
                var html = cbwireController.wire(
                    name="TestComponent",
                    params={ "title": "Whatever" },
                    key=""
                );
                expect( html ).toInclude( "Title: Whatever" );
            } );

            it( "should return getStyles()", function() {
                var styles = cbwireController.getStyles();
                expect( styles ).toBeString();
                expect( styles ).toInclude( "<!-- CBWIRE STYLES -->" );
            } );

            it( "should return getScripts()", function() {
                var scripts = cbwireController.getScripts();
                expect( scripts ).toBeString();
                expect( scripts ).toInclude( "<!-- CBWIRE SCRIPTS -->" );
            } );

            it( "should include a data-csrf token when calling getScripts()", function() {
                var scripts = cbwireController.getScripts();
                expect( scripts ).toInclude( "data-csrf" );
                expect( reFindNoCase( "data-csrf=""[A-Za-z0-9]+""", scripts ) ).toBeGT( 0 );
            } );

            it( "should provide a wirePersist() method", function() {
                var result = cbwireController.persist( "player" );
                expect( result.trim() ).toBe( "<div x-persist=""player"">" );
            } );

            it( "should provide a endWirePersist() method", function() {
                var result = cbwireController.endPersist();
                expect( result.trim() ).toBe( "</div>" );
            } );

			it( "can render component from ./wires folder using wire()", function() {
				var result = cbwireController.wire( "TestComponent" );
				expect( result ).toContain( "Title: CBWIRE Rocks!" );
			} );

			it( "can render component from nested folder using wire()", function() {
				var result = cbwireController.wire( "wires.nestedComponent.NestedFolderComponent" );
				expect( result ).toContain( "Nested folder component" );
			} );

			it( "throws error if it's unable to find a module component", function() {
				expect( function() {
					var result = cbwireController.wire( "missing@someModule" );
				} ).toThrow( type="ModuleNotFound" );
			} );

			it( "can render component from nested module using default wires location", function() {
				var result = cbwireController.wire( "NestedModuleDefaultComponent@testingmodule" );
				expect( result ).toContain( "Nested module component using default wires location" );
			} );

            it( "can load components from an external modules folder", function() {
                var result = cbwireController.wire( "should_load_external_modules@ExternalModule" );
                expect( result ).toInclude( "External Module Loaded" );
            } );
        });

        describe( "Preprocessors", function() {
            describe( "CBWIREPreprocessor", function() {
                beforeEach(function(currentSpec) {
                    // Assuming setup() initializes application environment
                    // and prepareMock() is a custom method to mock any dependencies, if necessary.
                    setup();
                    preprocessor = getInstance("CBWIREPreprocessor@cbwire");
                    prepareMock( preprocessor );
                });

                it("should parse and replace single cbwire tag with no arguments", function() {
                    var input = "<cbwire:testComponent/>";
                    var expected = "##wire( name=""testComponent"", params={ }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });

                it("should parse and replace cbwire tag with multiple arguments", function() {
                    var input = "<cbwire:testComponent :param1='value1' param2='value2'/>";
                    var expected = "##wire( name=""testComponent"", params={ param1=value1, param2='value2' }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });

                it("should correctly handle arguments with expressions", function() {
                    var input = "<cbwire:testComponent :expr='someExpression'/>";
                    var expected = "##wire( name=""testComponent"", params={ expr=someExpression }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });

                it("should maintain order and syntax of multiple attributes", function() {
                    var input = "<cbwire:testComponent attr1='foo' :expr='bar' attr2='baz'/>";
                    var expected = "##wire( name=""testComponent"", params={ attr1='foo', expr=bar, attr2='baz' }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });

                it("should replace multiple cbwire tags in a single content string", function() {
                    var input = "Here is a test <cbwire:firstComponent attr='value'/> and another <cbwire:secondComponent :expr='expression'/>";
                    var expected = "Here is a test ##wire( name=""firstComponent"", params={ attr='value' }, lazy=false )## and another ##wire( name=""secondComponent"", params={ expr=expression }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });

                it("should throw an exception for unparseable tags", function() {
                    var input = "<cbwire:testComponent :broken='noEndQuote>";
                    expect(function() {
                        preprocessor.handle(input);
                    }).toThrow( message="Parsing error: unable to process cbwire tag due to malformed attributes.");
                });

            } );

            describe("Teleport Preprocessing Tests", function() {

                beforeEach(function() {
                    // Create an instance of the component that handles teleport preprocessing
                    preprocessor = getInstance( "TeleportPreprocessor@cbwire" );
                });

                it("should replace @teleport with the correct template tag", function() {
                    var content = "@teleport(selector) content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });

                it("should handle single quotes around the selector", function() {
                    var content = "@teleport('selector') content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });

                it("should handle double quotes around the selector", function() {
                    var content = '@teleport("selector") content @endteleport';
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });

                it("should handle no quotes around the selector", function() {
                    var content = "@teleport(selector) content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });

                it("should handle spaces within the parentheses", function() {
                    var content = "@teleport(   selector   ) content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });

                it("should handle multiple teleport directives in the same content", function() {
                    var content = "@teleport(selector1) content1 @endteleport @teleport(selector2) content2 @endteleport";
                    var expected = '<template x-teleport="selector1"> content1 </template> <template x-teleport="selector2"> content2 </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });

                it("should handle nested teleport directives", function() {
                    var content = "@teleport(outer) @teleport(inner) content @endteleport @endteleport";
                    var expected = '<template x-teleport="outer"> <template x-teleport="inner"> content </template> </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });

                it("should not alter content without teleport directives", function() {
                    var content = "Normal content without directives";
                    var result = preprocessor.handle(content);
                    expect(result).toBe(content);
                });
            });

        } );
    }

    /**
     * Helper test method for creating incoming request payloads
     *
     * @data
     * @calls
     *
     * @return struct
     */
    private function incomingRequest(
        memo = {},
        data = {},
        calls = [],
        updates = {},
        csrfToken = ""
    ){

        var response = {
            "content": {
                "_token": arguments.csrfToken.len() ? arguments.csrfToken : getInstance( "CBWIREController@cbwire" ).generateCSRFToken(),
                "components": [
                    {
                        "calls": arguments.calls,
                        "snapshot": {
                            "data": arguments.data,
                            "memo": arguments.memo
                        },
                        "updates": arguments.updates
                    }
                ]
            }
        };

        response.content.components = response.content.components.map( function( _comp ) {
            _comp.snapshot = serializeJson( _comp.snapshot );
            return _comp;
        } );

        response.content = serializeJson( response.content );

        return response;
    }

    /**
     * Take a rendered HTML component and breaks out its snapshot,
     * effects, etc for analysis during tests.
     *
     * @return struct
     */
    private function parseRendering( html, index = 1 ) {
        local.result = {};
        // Determine outer element
        local.outerElementMatches = reMatchNoCase( "<([a-z]+)\s*", html );
        local.result[ "outerElement" ] = reFindNoCase( "<([a-z]+)\s*", html, 1, true ).match[ 2 ];
        // Parse snapshot
        local.result[ "snapshot" ] = parseSnapshot( html, index );
        // Parse effects
        local.result[ "effects" ] = parseEffects( html, index );
        return local.result;
    }

    /**
     * Parse the snapshot from a rendered HTML component
     *
     * @return struct
     */
    private function parseSnapshot( html, index = 1 ) {
        local.match = reMatchNoCase( "wire:snapshot=""([^""]+)", html )[ index ];
        local.regexMatches = reFindNoCase( "wire:snapshot=""([^""]+)", local.match, 1, true );
        local.snapshot = local.regexMatches.match[ 2 ];
        local.snapshot = replaceNoCase( local.snapshot, "&quot;", """", "all" );
        return deserializeJSON( local.snapshot );
    }

    /**
     * Parse the effects from a rendered HTML component
     *
     * @return struct
     */
    private function parseEffects( html, index = 1 ) {
        local.match = reMatchNoCase( "wire:effects=""([^""]+)", html )[ index ];
        local.regexMatches = reFindNoCase( "wire:effects=""([^""]+)", local.match, 1, true );
        local.effects = local.regexMatches.match[ 2 ];
        local.effects = replaceNoCase( local.effects, "&quot;", """", "all" );
        return deserializeJSON( local.effects );
    }

}
