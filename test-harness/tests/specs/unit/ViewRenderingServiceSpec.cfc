component extends="coldbox.system.testing.BaseTestCase" {

    
    function beforeAll() {
        variables.mockController = createStub();
        variables.mockUtility = createStub();
        
        variables.viewService = prepareMock( new cbwire.models.ViewRenderingService() );
        viewService.setCBWIREController( mockController );
        viewService.setUtilityService( mockUtility );
    }

    function run() {
        describe( "ViewRenderingService", function() {

            describe( "normalizeViewPath()", function() {

                it( "should return .bxm path when .bxm file exists", function() {
                    var input = "my.view.template";
                    var bxmAbsolutePath = expandPath( "/my/view/template.bxm" );
                    var cfmAbsolutePath = expandPath( "/my/view/template.cfm" );
                    var expectedPath = "/wires/my/view/template.bxm";

                    mockUtility.$( "fileExists" ).$args( bxmAbsolutePath ).$results( true );
                    mockUtility.$( "fileExists" ).$args( cfmAbsolutePath ).$results( false );

                    var result = viewService.normalizeViewPath( input );
                    expect( result ).toBe( expectedPath );
                });

                it( "should return .cfm path when only .cfm file exists", function() {
                    var input = "my.view.template";
                    var bxmAbsolutePath = expandPath( "/my/view/template.bxm" );
                    var cfmAbsolutePath = expandPath( "/my/view/template.cfm" );
                    var expectedPath = "/wires/my/view/template.cfm";

                    mockUtility.$( "fileExists" ).$args( bxmAbsolutePath ).$results( false );
                    mockUtility.$( "fileExists" ).$args( cfmAbsolutePath ).$results( true );

                    var result = viewService.normalizeViewPath( input );
                    expect( result ).toBe( expectedPath );
                });

                it( "should throw when neither .bxm nor .cfm exists", function() {
                    var input = "my.view.template";
                    var bxmAbsolutePath = expandPath( "/nonexistent/view.bxm" );
                    var cfmAbsolutePath = expandPath( "/nonexistent/view.cfm" );
                    var expectedPath = "/wires/my/view/template.cfm";

                    mockUtility.$( "fileExists" ).$args( bxmAbsolutePath ).$results( false );
                    mockUtility.$( "fileExists" ).$args( cfmAbsolutePath ).$results( false );

                    expect( function() {
                        viewService.normalizeViewPath( "nonexistent.view" );
                    }).toThrow( "CBWIREException" );
                });

                it( "should return path with .bxm for tmp path when .bxm exists", function() {
                    var input = "cbwire.models.tmp.componentName";

                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.bxm" ) ).$results( true );
                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.cfm" ) ).$results( false );

                    var result = viewService.normalizeViewPath( input );
                    expect( result ).toBe( "/cbwire/models/tmp/componentName.bxm" );
                });

                it( "should return path with .cfm for tmp path when .cfm exists", function() {
                    var input = "cbwire.models.tmp.componentName";

                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.bxm" ) ).$results( false );
                    mockUtility.$( "fileExists" ).$args( expandPath( "/cbwire/models/tmp/componentName.cfm" ) ).$results( true );

                    var result = viewService.normalizeViewPath( input );
                    expect( result ).toBe( "/cbwire/models/tmp/componentName.cfm" );
                });
            });

            describe( "getTemplatePath()", function() {

                it( "should return full module path when module path is used", function() {
                    var mockWire = prepareMock( createStub() );
                    mockWire.$( "_getModuleName", "exampleModule" );
                    mockWire.$( "_getComponentName", "myComponent@cbwire" );

                    mockController.$( "getModuleRootPath", "modules_app/exampleModule" );

                    var result = viewService.getTemplatePath( mockWire, "my@view" );
                    expect( result ).toBe( "modules_app/exampleModule.wires.myComponent" );
                });

                it( "should return default path when not a module path", function() {
                    var mockWire = createStub();
                    var result = viewService.getTemplatePath( mockWire, "some.view" );
                    expect( result ).toBe( "wires.some.view" );
                });
            });

            describe( "isModulePath()", function() {
                it( "should return true for paths with @", function() {
                    expect( viewService.isModulePath( "some@path" ) ).toBeTrue();
                });

                it( "should return false for paths without @", function() {
                    expect( viewService.isModulePath( "some/path" ) ).toBeFalse();
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

                    viewService.captureTemplateReturnValues( mockWire, returnValues );

                    mockWire.$once( "_trackScript" );
                    mockWire.$once( "_trackAsset" );
                });

            });

        });
    }
}
