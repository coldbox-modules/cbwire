component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        // Mock module settings
        variables.mockModuleSettings = {
            "secret": "test-secret-key",
            "moduleRootPath": "/path/to/module"
        };

                // Create the service instance
        variables.checksumService = new cbwire.models.services.ChecksumService();
        
        // Inject mock module settings
        variables.checksumService.setModuleSettings(variables.mockModuleSettings);
    }

    function run() {
        describe("ChecksumService", function() {
           
            describe("calculateChecksum()", function() {
                
                it("should calculate checksum for simple struct", function() {
                    var snapshot = {
                        "name": "test",
                        "value": 123
                    };
                    
                    var result = checksumService.calculateChecksum(snapshot);
                    
                    expect(snapshot).toHaveKey("checksum");
                    expect(snapshot.checksum).toBeString();
                    expect(snapshot.checksum).notToBeEmpty();
                    expect(isJson(result)).toBeTrue();
                });

                it("should replace existing checksum", function() {
                    var snapshot = {
                        "name": "test",
                        "checksum": "old-checksum"
                    };
                    
                    var originalChecksum = snapshot.checksum;
                    checksumService.calculateChecksum(snapshot);
                    
                    expect(snapshot.checksum).notToBe(originalChecksum);
                });

                it("should produce consistent checksums for same data", function() {
                    var snapshot1 = {
                        "name": "test",
                        "value": 123
                    };
                    var snapshot2 = {
                        "name": "test", 
                        "value": 123
                    };
                    
                    checksumService.calculateChecksum(snapshot1);
                    checksumService.calculateChecksum(snapshot2);
                    
                    expect(snapshot1.checksum).toBe(snapshot2.checksum);
                });

                it("should produce different checksums for different data", function() {
                    var snapshot1 = {
                        "name": "test1",
                        "value": 123
                    };
                    var snapshot2 = {
                        "name": "test2",
                        "value": 123
                    };
                    
                    checksumService.calculateChecksum(snapshot1);
                    checksumService.calculateChecksum(snapshot2);
                    
                    expect(snapshot1.checksum).notToBe(snapshot2.checksum);
                });

                it( "should produce same checks for deeply nested ordered structures that are not in identical order", function() {
                    var snapshot1 = [:];
                    snapshot1["user"] = {
                        "name": "John",
                        "details": {
                            "age": 30,
                            "city": "NYC"
                        }
                    };
                    snapshot1["items"] = [1, 2, 3];

                    var snapshot2 = [:];
                    snapshot2["items"] = [1, 2, 3];
                    snapshot2["user"] = {
                        "details": {
                            "city": "NYC",
                            "age": 30
                        },
                        "name": "John"
                    };
                    
                    checksumService.calculateChecksum(snapshot1);
                    checksumService.calculateChecksum(snapshot2);
                    
                    expect(snapshot1.checksum).toBe(snapshot2.checksum);
                });

                it("should handle nested structures", function() {
                    var snapshot = {
                        "user": {
                            "name": "John",
                            "details": {
                                "age": 30,
                                "city": "NYC"
                            }
                        },
                        "items": [1, 2, 3]
                    };
                    
                    var result = checksumService.calculateChecksum(snapshot);
                    
                    expect(snapshot).toHaveKey("checksum");
                    expect(isJson(result)).toBeTrue();
                });

                it("should handle arrays", function() {
                    var snapshot = {
                        "items": ["item1", "item2", "item3"],
                        "numbers": [1, 2, 3]
                    };
                    
                    checksumService.calculateChecksum(snapshot);
                    
                    expect(snapshot).toHaveKey("checksum");
                    expect(snapshot.checksum).toBeString();
                });

                it("should handle null values", function() {
                    var snapshot = {
                        "name": "test",
                        "nullValue": javaCast("null", ""),
                        "regularValue": "test"
                    };
                    
                    expect(function() {
                        checksumService.calculateChecksum(snapshot);
                    }).notToThrow();
                    
                    expect(snapshot).toHaveKey("checksum");
                });

                it("should handle empty structures", function() {
                    var snapshot = {};
                    
                    checksumService.calculateChecksum(snapshot);
                    
                    expect(snapshot).toHaveKey("checksum");
                    expect(snapshot.checksum).toBeString();
                });

                it("should handle complex mixed data types", function() {
                    var snapshot = {
                        "string": "test",
                        "number": 123,
                        "boolean": true,
                        "array": [1, "two", true],
                        "struct": {
                            "nested": "value"
                        },
                        "nullValue": javaCast("null", "")
                    };
                    
                    expect(function() {
                        checksumService.calculateChecksum(snapshot);
                    }).notToThrow();
                    
                    expect(snapshot).toHaveKey("checksum");
                });

            });

            describe("validateChecksum()", function() {
                
                it("should validate correct checksum", function() {
                    // Start with a clean snapshot
                    var originalSnapshot = {
                        "name": "test",
                        "value": 123
                    };
                    
                    // Create a copy for checksum calculation
                    var snapshotForChecksum = duplicate(originalSnapshot);
                    
                    // Calculate checksum - this modifies snapshotForChecksum and returns JSON
                    var jsonString = checksumService.calculateChecksum(snapshotForChecksum);
                    
                    // Debug: let's see what we're working with
                    var parsedResult = deserializeJSON(jsonString);
                    debug("Calculated checksum: " & parsedResult.checksum);
                    debug("JSON string: " & jsonString);
                    
                    // validateChecksum expects the JSON string
                    expect(function() {
                        checksumService.validateChecksum(jsonString);
                    }).notToThrow();
                });

                it("should validate checksum with incoming checksum in snapshot", function() {
                    var snapshot = {
                        "name": "test",
                        "value": 123,
                        "checksum": "1234"
                    };
                    
                    // Calculate checksum
                    var jsonString = checksumService.calculateChecksum(snapshot);
                    
                    // Deserialize to get the checksum
                    var deserializedSnapshot = deserializeJSON(jsonString);
                    
                    // Validate the checksum
                    expect(function() {
                        checksumService.validateChecksum(serializeJson(deserializedSnapshot));
                    }).notToThrow();
                });

                it("should throw error for invalid JSON", function() {
                    var invalidJson = "invalid json string";
                    
                    expect(function() {
                        checksumService.validateChecksum(invalidJson);
                    }).toThrow("CBWIRECorruptPayloadException");
                });

                it("should throw error for missing checksum", function() {
                    var snapshotWithoutChecksum = {
                        "name": "test",
                        "value": 123
                    };
                    var jsonString = serializeJson(snapshotWithoutChecksum);
                    
                    expect(function() {
                        checksumService.validateChecksum(jsonString);
                    }).toThrow("CBWIRECorruptPayloadException");
                });

                it("should throw error for tampered data", function() {
                    var snapshot = {
                        "name": "test",
                        "value": 123
                    };
                    
                    var jsonString = checksumService.calculateChecksum(snapshot);
                    var tamperedData = deserializeJSON(jsonString);
                    tamperedData.name = "tampered";
                    var tamperedJson = serializeJson(tamperedData);
                    
                    expect(function() {
                        checksumService.validateChecksum(tamperedJson);
                    }).toThrow("CBWIRECorruptPayloadException");
                });

                it("should validate complex nested structures", function() {
                    var snapshot = {
                        "user": {
                            "name": "John",
                            "details": {
                                "age": 30,
                                "preferences": ["coffee", "tea"]
                            }
                        },
                        "items": [
                            {"name": "item1", "value": 100},
                            {"name": "item2", "value": 200}
                        ]
                    };
                    
                    var jsonString = checksumService.calculateChecksum(snapshot);
                    
                    expect(function() {
                        checksumService.validateChecksum(jsonString);
                    }).notToThrow();
                });

            });

            describe("Edge Cases", function() {
                
                it("should handle very large structures", function() {
                    var largeSnapshot = {};
                    for (var i = 1; i <= 1000; i++) {
                        largeSnapshot["key" & i] = "value" & i;
                    }
                    
                    expect(function() {
                        checksumService.calculateChecksum(largeSnapshot);
                    }).notToThrow();
                    
                    expect(largeSnapshot).toHaveKey("checksum");
                });

                it("should handle special characters in keys and values", function() {
                    var snapshot = {
                        "key with spaces": "value with spaces",
                        "key-with-dashes": "value-with-dashes",
                        "key_with_underscores": "value_with_underscores",
                        "keyWithUnicode": "value with unicode: ñáéíóú"
                    };
                    
                    expect(function() {
                        checksumService.calculateChecksum(snapshot);
                    }).notToThrow();
                });

                it("should handle empty arrays and structs", function() {
                    var snapshot = {
                        "emptyArray": [],
                        "emptyStruct": {},
                        "regularValue": "test"
                    };
                    
                    expect(function() {
                        checksumService.calculateChecksum(snapshot);
                    }).notToThrow();
                });

            });

            describe("Security", function() {
                
                it("should use module secret when available", function() {
                    var snapshot1 = {"test": "value"};
                    var snapshot2 = {"test": "value"};
                    
                    // Calculate with current secret
                    checksumService.calculateChecksum(snapshot1);
                    
                    // Change secret
                    var newModuleSettings = duplicate(mockModuleSettings);
                    newModuleSettings.secret = "different-secret";
                    checksumService.setModuleSettings(newModuleSettings);
                    
                    // Calculate with different secret
                    checksumService.calculateChecksum(snapshot2);
                    
                    // Checksums should be different
                    expect(snapshot1.checksum).notToBe(snapshot2.checksum);
                    
                    // Reset for other tests
                    checksumService.setModuleSettings(mockModuleSettings);
                });

            });

        });
    }

    /**
     * Helper function to invoke private methods for testing
     */
    private function invokePrivateMethod(methodName, args = []) {
        var method = checksumService[methodName];
        return method(argumentCollection = args);
    }

}