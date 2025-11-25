component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        // Create the service instance
        variables.builder = new cbwire.models.SingleFileComponentBuilder();
    }

    function run() {
        describe( "SingleFileComponentBuilder", function() {

            describe( "parseContents()", function() {

                it( "should track the line number where @startWire begins", function() {
                    // Create a temp file with known content
                    var testContent = "<cfscript>" & chr( 10 ) &
                                      "// some comment" & chr( 10 ) &
                                      "// @startWire" & chr( 10 ) &
                                      "    data = { 'name': 'test' };" & chr( 10 ) &
                                      "// @endWire" & chr( 10 ) &
                                      "</cfscript>" & chr( 10 ) &
                                      "<cfoutput><div>test</div></cfoutput>";
                    
                    var tempFile = getTempDirectory() & "testWire_" & createUUID() & ".cfm";
                    fileWrite( tempFile, testContent );

                    try {
                        var result = variables.builder.parseContents( tempFile );
                        
                        // @startWire is on line 3
                        expect( result.startWireLineNumber ).toBe( 3 );
                        expect( result ).toHaveKey( "singleFileContents" );
                        expect( result ).toHaveKey( "remainingContents" );
                        expect( result ).toHaveKey( "extendsPath" );
                    } finally {
                        // Clean up temp file
                        if ( fileExists( tempFile ) ) {
                            fileDelete( tempFile );
                        }
                    }
                });

                it( "should return 0 for startWireLineNumber when @startWire is not found", function() {
                    // Create a temp file without @startWire
                    var testContent = "<cfscript>" & chr( 10 ) &
                                      "// some comment" & chr( 10 ) &
                                      "</cfscript>" & chr( 10 ) &
                                      "<cfoutput><div>test</div></cfoutput>";
                    
                    var tempFile = getTempDirectory() & "testWireNoAnnotation_" & createUUID() & ".cfm";
                    fileWrite( tempFile, testContent );

                    try {
                        var result = variables.builder.parseContents( tempFile );
                        
                        expect( result.startWireLineNumber ).toBe( 0 );
                    } finally {
                        // Clean up temp file
                        if ( fileExists( tempFile ) ) {
                            fileDelete( tempFile );
                        }
                    }
                });

                it( "should correctly parse the wire contents between @startWire and @endWire", function() {
                    // Create a temp file with known content
                    var testContent = "<cfscript>" & chr( 10 ) &
                                      "// @startWire" & chr( 10 ) &
                                      "    data = { 'counter': 0 };" & chr( 10 ) &
                                      "    function increment() { data.counter++; }" & chr( 10 ) &
                                      "// @endWire" & chr( 10 ) &
                                      "</cfscript>" & chr( 10 ) &
                                      "<cfoutput><div>test</div></cfoutput>";
                    
                    var tempFile = getTempDirectory() & "testWireContents_" & createUUID() & ".cfm";
                    fileWrite( tempFile, testContent );

                    try {
                        var result = variables.builder.parseContents( tempFile );
                        
                        // Wire contents should include the data and function definitions
                        expect( result.singleFileContents ).toInclude( "data = { 'counter': 0 }" );
                        expect( result.singleFileContents ).toInclude( "function increment()" );
                        
                        // Remaining contents should include the template part
                        expect( result.remainingContents ).toInclude( "<cfoutput>" );
                        expect( result.remainingContents ).toInclude( "<div>test</div>" );
                    } finally {
                        // Clean up temp file
                        if ( fileExists( tempFile ) ) {
                            fileDelete( tempFile );
                        }
                    }
                });

            });

        });
    }

}
