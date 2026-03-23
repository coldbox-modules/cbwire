component extends="coldbox.system.testing.BaseTestCase" {


    function beforeAll() {
        variables.mockController = createStub();
        variables.mockUtility = createStub();
        variables.mockChecksumService = createStub();
        variables.mockValidationService = createStub();
        variables.mockRequestService = createStub();

        variables.renderService = prepareMock( new cbwire.models.services.RenderService() );
        renderService.setCBWIREController( mockController );
        renderService.setUtilityService( mockUtility );
        renderService.setChecksumService( mockChecksumService );
        renderService.setValidationService( mockValidationService );
        renderService.setRequestService( mockRequestService );
    }

    function run() {
        describe( "RenderService", function() {

            describe( "render()", function() {

                it( "should render with initial attributes on initial load", function() {
                    var mockWire = createStub();
                    mockWire.$( "get_initialLoad", true );
                    mockWire.$( "get_id", "abc123" );
                    mockWire.$( "get_listeners", {} );
                    mockWire.$( "get_scripts", {} );
                    mockWire.$( "_getSnapshot", { foo: "bar" } );

                    mockChecksumService.$( "calculateChecksum", serializeJson( { checksum: "abc" } ) );

                    var baseHtml = "<div>content</div>";
                    var output = renderService.render( mockWire, baseHtml );

                    expect( output ).toInclude( "abc123" );
                    expect( output ).toInclude( "abc" );
                    expect( output ).toInclude( "<div" );
                    expect( output ).toInclude( "</div>" );
                });

                it( "should render trimmed HTML with no extra attributes on subsequent request", function() {
                    var mockWire = createStub();
                    mockWire.$( "get_initialLoad", false );
                    mockWire.$( "get_id", "xyz789" );

                    var baseHtml = "   <div>updated</div>   ";
                    var output = renderService.render( mockWire, baseHtml );

                    expect( output ).toInclude( "xyz789" );
                    expect( output ).toInclude( "<div" );
                    expect( output ).toInclude( "</div>" );
                    expect( output ).notToInclude( "  " ); // trimmed
                });

                xit( "should throw if HTML does not have a single outer element", function() {
                    var mockWire = createStub();
                    mockWire.$( "get_initialLoad", false );
                    mockWire.$( "get_id", "test" );

                    var invalidHtml = "<div></div><div></div>";

                    expect( function() {
                        renderService.render( mockWire, invalidHtml );
                    } ).toThrow();
                });

                it( "should insert wire:snapshot and wire:id attributes on initial load", function() {
                    var mockWire = createStub();
                    mockWire.$( "get_initialLoad", true );
                    mockWire.$( "get_id", "abc123" );
                    mockWire.$( "get_listeners", { someEvent: "someAction" } );
                    mockWire.$( "get_scripts", { scriptA: "console.log('a')" } );
                    mockWire.$( "_getSnapshot", { foo: "bar" } );

                    mockChecksumService.$( "calculateChecksum", serializeJson( { checksum: "xyz" } ) );

                    var html = "<div>hello</div>";
                    var result = renderService.render( mockWire, html );

                    expect( result ).toInclude( 'wire:snapshot="' );
                    expect( result ).toInclude( 'wire:id="abc123"' );
                    expect( result ).toInclude( 'wire:effects=' );
                });

                it( "should insert wire:id attribute only on subsequent render", function() {
                    var mockWire = createStub();
                    mockWire.$( "get_initialLoad", false );
                    mockWire.$( "get_id", "def456" );

                    var html = "<div>later</div>";
                    var result = renderService.render( mockWire, html );

                    expect( result ).toInclude( 'wire:id="def456"' );
                    expect( result ).notToInclude( "wire:snapshot" );
                    expect( result ).notToInclude( "wire:effects" );
                });


            });

            describe( "renderViewContent()", function() {

                it( "should render with test encapsulator", function() {
                    var wire = prepareMock( createStub() );
                    wire.$( "get_renderedContent", "" );
                    wire.$( "set_renderedContent" );
                    wire.$( "get_id", "abc123" );

                    var testTemplate = "/tests/resources/RendererStub.cfm"; // You control this
                    var result = renderService.renderViewContent( wire, "fake.path", {}, testTemplate );

                    debug(result);
                    expect( result ).toInclude( "Rendered abc123" );
                });

            });

            describe( "getOuterElement()", function() {

                it( "should return the outer element tag name for a simple div", function() {
                    var html = "<div></div>";
                    var result = renderService.getOuterElement( html );
                    expect( result ).toBe( "div" );
                });

                it( "should return the outer tag name when attributes are present", function() {
                    var html = '<section class="wrapper" id="main">';
                    var result = renderService.getOuterElement( html );
                    expect( result ).toBe( "section" );
                });

                it( "should ignore leading whitespace before tag", function() {
                    var html = '   <article data-id="1">';
                    var result = renderService.getOuterElement( html );
                    expect( result ).toBe( "article" );
                });

                it( "should handle uppercase tag names", function() {
                    var html = "<DIV class='test'>";
                    var result = renderService.getOuterElement( html );
                    expect( result ).toBe( "DIV" );
                });

                it( "should throw CBWIREException when no HTML elements are present", function() {
                    var html = "no tags here";
                    expect( function() {
                        renderService.getOuterElement( html );
                    }).toThrow( "CBWIREException" );
                    var html = "<div>tags here</div>";
                    expect( function() {
                        renderService.getOuterElement( html );
                    }).notToThrow( "CBWIREException" );

                });

                it( "should throw CBWIREException with descriptive message for empty HTML", function() {
                    var html = "";
                    expect( function() {
                        renderService.getOuterElement( html );
                    }).toThrow( "CBWIREException" );
                });

                it( "should throw CBWIREException for HTML with only text content", function() {
                    var html = "Just some text content without any tags";
                    expect( function() {
                        renderService.getOuterElement( html );
                    }).toThrow( "CBWIREException" );
                });

                it( "should return the first tag if multiple are present", function() {
                    var html = "<div><span></span></div>";
                    var result = renderService.getOuterElement( html );
                    expect( result ).toBe( "div" );
                });

            });

            describe( "getComponentTag()", function() {

                it( "should return 'div' for simple div rendering", function() {
                    var result = renderService.getComponentTag( "<div>content</div>" );
                    expect( result ).toBe( "div" );
                });

                it( "should return tag name with attributes present", function() {
                    var result = renderService.getComponentTag( '<section id="main" class="wrapper">' );
                    expect( result ).toBe( "section" );
                });

                it( "should handle leading whitespace", function() {
                    var result = renderService.getComponentTag( "   <article>" );
                    expect( result ).toBe( "article" );
                });

                it( "should handle uppercase tags", function() {
                    var result = renderService.getComponentTag( "<SPAN class='highlight'>" );
                    expect( result ).toBe( "SPAN" );
                });

                it( "should throw CBWIREException if no tag is found", function() {
                    expect( function() {
                        renderService.getComponentTag( "no valid html" );
                    } ).toThrow( "CBWIREException" );
                });

                it( "should throw CBWIREException on empty string", function() {
                    expect( function() {
                        renderService.getComponentTag( "" );
                    } ).toThrow( "CBWIREException" );
                });

            });

            describe( "validateSingleOuterElement()", function() {

                it( "should allow single outer div", function() {
                    var html = "<div><span>ok</span></div>";
                    expect( function() {
                        renderService.validateSingleOuterElement( html );
                    } ).notToThrow();
                });

                it( "should allow void elements inside a single outer div", function() {
                    var html = '<div><br><img src="x.png" /></div>';
                    expect( function() {
                        renderService.validateSingleOuterElement( html );
                    } ).notToThrow();
                });

                xit( "should throw when there are multiple outer elements", function() {
                    var html = "<div>One</div><div>Two</div>";
                    expect( function() {
                        renderService.validateSingleOuterElement( html );
                    } ).toThrow( "CBWIRETemplateException" );
                });

                xit( "should throw when HTML is empty", function() {
                    var html = "";
                    expect( function() {
                        renderService.validateSingleOuterElement( html );
                    } ).toThrow( "ApplicationException" );
                });

                xit( "should throw when outer tags do not match", function() {
                    var html = "<section><p>Mismatch</p></div>";
                    expect( function() {
                        renderService.validateSingleOuterElement( html );
                    } ).toThrow( "CBWIRETemplateException" );
                });

                xit( "should throw when closing tag is missing", function() {
                    var html = "<div><span>Missing</span>";
                    expect( function() {
                        renderService.validateSingleOuterElement( html );
                    } ).toThrow( "CBWIRETemplateException" );
                });

            });

            describe( "normalizeViewPath()", function() {

                it( "should return .bxm path when .bxm file exists", function() {
                    var input = "my.view.template";
					// simulate the components variables._path which is what is passed to the wire() method
					var component_path = "my.view.template";
                    var bxmAbsolutePath = expandPath( "/my/view/template.bxm" );
                    var cfmAbsolutePath = expandPath( "/my/view/template.cfm" );
                    var expectedPath = "/wires/my/view/template.bxm";

                    mockUtility.$( "fileExists" ).$args( bxmAbsolutePath ).$results( true );
                    mockUtility.$( "fileExists" ).$args( cfmAbsolutePath ).$results( false );

                    var result = renderService.normalizeViewPath( input, component_path );
                    expect( result ).toBe( expectedPath );
                });

                it( "should return .cfm path when only .cfm file exists", function() {
                    var input = "my.view.template";
					// simulate the components variables._path which is what is passed to the wire() method
					var component_path = "my.view.template";
                    var bxmAbsolutePath = expandPath( "/my/view/template.bxm" );
                    var cfmAbsolutePath = expandPath( "/my/view/template.cfm" );
                    var expectedPath = "/wires/my/view/template.cfm";

                    mockUtility.$( "fileExists" ).$args( bxmAbsolutePath ).$results( false );
                    mockUtility.$( "fileExists" ).$args( cfmAbsolutePath ).$results( true );

                    var result = renderService.normalizeViewPath( input, component_path );
                    expect( result ).toBe( expectedPath );
                });

                it( "should return .cfm module path when wire is located in module wires directory", function() {
                    var input = "modules_app.testingModule.wires.twoFileModuleComponent";
					// simulate the components variables._path which is what is passed to the wire() method
					var component_path = "twoFileModuleComponent@testingModule";
					// use full path to module wire
                    var bxmAbsolutePath = expandPath( "../modules_app/testingModule/wires/twoFileModuleComponent.bxm" );
                    var cfmAbsolutePath = expandPath( "../modules_app/testingModule/wires/twoFileModuleComponent.cfm" );

                    var expectedPath = "/modules_app/testingModule/wires/twoFileModuleComponent.cfm";
					// mock the file exists calls for both .bxm and .cfm paths
                    mockUtility.$( "fileExists" ).$args( bxmAbsolutePath ).$results( false );
                    mockUtility.$( "fileExists" ).$args( cfmAbsolutePath ).$results( true );

                    var result = renderService.normalizeViewPath( input, component_path );
                    expect( result ).toBe( expectedPath );
                });

                it( "should throw when neither .bxm nor .cfm exists", function() {
                    var input = "my.view.template";
					// simulate the components variables._path which is what is passed to the wire() method
					var component_path = "my.view.template";
                    var bxmAbsolutePath = expandPath( "/nonexistent/view.bxm" );
                    var cfmAbsolutePath = expandPath( "/nonexistent/view.cfm" );
                    var expectedPath = "/wires/my/view/template.cfm";

                    mockUtility.$( "fileExists" ).$args( bxmAbsolutePath ).$results( false );
                    mockUtility.$( "fileExists" ).$args( cfmAbsolutePath ).$results( false );

                    expect( function() {
                        renderService.normalizeViewPath( "nonexistent.view", component_path );
                    }).toThrow( "CBWIREException" );
                });

                it( "should return path with .bxm for tmp path when .bxm exists", function() {
                    var input = "cbwire.models.tmp.componentName";
					// simulate the components variables._path which is what is passed to the wire() method
					var component_path = "cbwire.models.tmp.componentName";

                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.bxm" ) ).$results( true );
                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.cfm" ) ).$results( false );

                    var result = renderService.normalizeViewPath( input, component_path );
                    expect( result ).toBe( "/cbwire/models/tmp/componentName.bxm" );
                });

                it( "should return path with .cfm for tmp path when .cfm exists", function() {
                    var input = "cbwire.models.tmp.componentName";
					// simulate the components variables._path which is what is passed to the wire() method
					var component_path = "cbwire.models.tmp.componentName";

                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.bxm" ) ).$results( false );
                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.cfm" ) ).$results( true );

                    var result = renderService.normalizeViewPath( input, component_path );
                    expect( result ).toBe( "/cbwire/models/tmp/componentName.cfm" );
                });

            });

            describe( "getTemplatePath()", function() {

                it( "should return full module path when module path is used", function() {
                    var mockWire = createStub();
                    mockWire.$( "_getModuleName", "exampleModule" );
                    mockWire.$( "_getComponentName", "myComponent@cbwire" );

                    mockController.$( "getModuleRootPath", "modules_app/exampleModule" );

                    var result = renderService.getTemplatePath( mockWire, "my@view" );
                    expect( result ).toBe( "modules_app/exampleModule.wires.myComponent" );
                });

                it( "should return default path when not a module path", function() {
                    var mockWire = createStub();
                    var result = renderService.getTemplatePath( mockWire, "some.view" );
                    expect( result ).toBe( "wires.some.view" );
                });
            });

            describe( "isModulePath()", function() {
                it( "should return true for paths with @", function() {
                    expect( renderService.isModulePath( "some@path" ) ).toBeTrue();
                });

                it( "should return false for paths without @", function() {
                    expect( renderService.isModulePath( "some/path" ) ).toBeFalse();
                });
            });

            describe( "captureTemplateReturnValues()", function() {

                it( "should track script and asset tags", function() {
                    var mockWire = createStub();
                    mockWire.$( "_getCompileTimeKey", "abc123" );
                    mockWire.$( "_trackScript" );
                    mockWire.$( "_trackAsset" );

                    mockController.$( "getRequestAssets", {} );

                    var returnValues = {
                        "script1": "<script>...</script>",
                        "assets1": "<link rel='stylesheet'>"
                    };

                    renderService.captureTemplateReturnValues( mockWire, returnValues );

                    mockWire.$once( "_trackScript" );
                    mockWire.$once( "_trackAsset" );
                });

            });

            describe( "generateWireEffectsAttribute()", function() {

                it( "should return encoded JSON with listeners only", function() {
                    var listeners = { "someEvent": "someAction", "anotherEvent": "anotherAction" };
                    var scripts = {};

                    var result = renderService.generateWireEffectsAttribute( listeners, scripts );
                    var decoded = deserializeJSON( decodeForHTML( result ) );

                    expect( decoded ).toHaveKey( "listeners" );
                    expect( decoded.listeners ).toInclude( "someEvent" );
                    expect( decoded.listeners ).toInclude( "anotherEvent" );
                    expect( decoded ).notToHaveKey( "scripts" );
                });

                it( "should return encoded JSON with scripts only", function() {
                    var listeners = {};
                    var scripts = { init: "console.log('init')" };

                    var result = renderService.generateWireEffectsAttribute( listeners, scripts );
                    var decoded = deserializeJSON( decodeForHTML( result ) );

                    expect( decoded ).toHaveKey( "scripts" );
                    expect( decoded.scripts ).toHaveKey( "init" );
                    expect( decoded ).notToHaveKey( "listeners" );
                });

                it( "should return encoded JSON with both listeners and scripts", function() {
                    var listeners = { "someEvent": "someAction" };
                    var scripts = { foo: "bar" };

                    var result = renderService.generateWireEffectsAttribute( listeners, scripts );
                    var decoded = deserializeJSON( decodeForHTML( result ) );

                    expect( decoded ).toHaveKey( "listeners" );
                    expect( decoded ).toHaveKey( "scripts" );
                    expect( decoded.listeners ).toInclude( "someEvent" );
                });

                it( "should return encoded empty array when both are empty", function() {
                    var listeners = {};
                    var scripts = {};

                    var result = renderService.generateWireEffectsAttribute( listeners, scripts );
                    expect( result ).toBe( "[]" );
                });

                it( "should encode attribute safely", function() {
                    var listeners = { "someEvent": "someAction" };
                    var scripts = {};

                    var result = renderService.generateWireEffectsAttribute( listeners, scripts );
                    expect( isJson( decodeForHTML( result ) ) ).toBeTrue();
                });

            });

            describe( "encodeAttribute()", function() {

                it( "should encode double quotes", function() {
                    var input = 'some "quoted" value';
                    var result = renderService.encodeAttribute( input );
                    expect( result ).toInclude( "&quot;" );
                });

                it( "should encode angle brackets", function() {
                    var input = "<script>alert('xss')</script>";
                    var result = renderService.encodeAttribute( input );
                    expect( result ).notToInclude( "<" );
                    expect( result ).notToInclude( ">" );
                });

                it( "should encode ampersands", function() {
                    var input = "name=foo&value=bar";
                    var result = renderService.encodeAttribute( input );
                    expect( result ).toInclude( "&amp;" );
                });

                it( "should return same value if no special characters", function() {
                    var input = "safeValue123";
                    var result = renderService.encodeAttribute( input );
                    expect( result ).toBe( "safeValue123" );
                });

                it( "should encode JSON string safely", function() {
                    var input = serializeJSON( { foo: "<bar>" } );
                    var result = renderService.encodeAttribute( input );
                    expect( isJson( decodeForHTML( result ) ) ).toBeTrue();
                });

            });

        });
    }
}
