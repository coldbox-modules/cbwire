component extends="coldbox.system.testing.BaseInterceptorTest" interceptor="cbwire.interceptors.AutoInjectAssets"{

    /*********************************** LIFE CYCLE Methods ***********************************/

    function beforeAll(){
        // interceptor configuration properties, if any
        configProperties = {};
        // init and configure interceptor
        super.setup();
        // we are now ready to test this interceptor
        interceptor.$( "getStyles", "<!-- CBWIRE Styles -->" );
        interceptor.$( "getScripts", "<!-- CBWIRE Scripts -->" );
    }

    function afterAll(){
    }

    /*********************************** BDD SUITES ***********************************/

    function run(){

        describe( "interceptors.test", function(){

            it( "should configure correctly", function(){
                interceptor.configure();
            });

            it( "does not inject assets if set to false", function() {
                interceptor.$( "shouldInject", false );

                var data = {
                    "renderedContent": "
                        <html>
                            <head>
                                <title>Some title</title>
                            </head>
                            <body>
                                Some HTML
                            </body>
                        </html>
                    "
                };

                var event = mockRequestService.getContext();

                interceptor.preRender( data=data, event=event );

                expect( interceptor.$once( "getStyles" ) ).toBeFalse();
                expect( interceptor.$once( "getScripts" ) ).toBeFalse();
                expect( data.renderedContent ).notToContain( "<!-- CBWIRE Styles -->" );
                expect( data.renderedContent ).notToContain( "<!-- CBWIRE Scripts -->" );
            } );

            it( "does inject assets if set to true", function() {
                interceptor.$( "shouldInject", true );

                var data = {
                    "renderedContent": "
                        <html>
                            <head>
                                <title>Some title</title>
                            </head>
                            <body>
                                Some HTML
                            </body>
                        </html>
                    "
                };

                var event = mockRequestService.getContext();

                interceptor.preRender( data=data, event=event );

                expect( interceptor.$once( "getStyles" ) ).toBeTrue();
                expect( interceptor.$once( "getScripts" ) ).toBeTrue();
                expect( data.renderedContent ).toContain( "<!-- CBWIRE Styles -->" );
                expect( data.renderedContent ).toContain( "<!-- CBWIRE Scripts -->" );
            } );


        });

    }

}