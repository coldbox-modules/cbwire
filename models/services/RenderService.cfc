component accessors="true" singleton {


    property name="cbwireController" inject="CBWIREController@cbwire";
    property name="checksumService" inject="ChecksumService@cbwire";
    property name="utilityService" inject="UtilityService@cbwire";
    property name="validationService" inject="ValidationService@cbwire";


    /**
     * Renders the HTML for a Livewire component, ensuring it has a single outer element.
     * If this is the initial load, it encodes the snapshot and inserts Livewire attributes.
     *
     * @wire Wire | The wire instance for the component being rendered.
     * @baseHtml string | The base HTML content to be processed.
     *
     * @return string The processed HTML with Livewire attributes.
     */
    function render( required wire, required baseHtml ) {
        local.trimmedHTML = trim( arguments.baseHtml );
        // Validate the HTML content to ensure it has a single outer element
        validateSingleOuterElement( local.trimmedHTML );
        // If this is the initial load, encode the snapshot and insert Livewire attributes
        if ( arguments.wire.get_initialLoad() ) {
            // Encode the snapshot for HTML attribute inclusion and process the view content
            local.snapshotEncoded = encodeAttribute( checksumService.calculateChecksum( arguments.wire._getSnapshot() ) );
            return insertInitialLivewireAttributes( local.trimmedHTML, local.snapshotEncoded, arguments.wire.get_id(), arguments.wire.get_listeners(), arguments.wire.get_scripts() );
        } else {
            // Return the trimmed HTML content
            return insertSubsequentLivewireAttributes( arguments.wire.get_id(), local.trimmedHTML );
        }
    }

    /**
     * Renders the content of a view template file.
     * This method is used internally by the view method to render the content of a view template.
     *
     * @wire Wire | The wire instance for the component being rendered.
     * @normalizedPath string | The normalized path to the view template file.
     * @params struct | The parameters to pass to the view template.
     *
     * @return The rendered content of the view template.
     */
    function renderViewContent(
            wire,
            normalizedPath,
            params = {},
            template = "/cbwire/views/RendererEncapsulator.cfm"
        ){
        if ( !wire.get_renderedContent().len() ) {
            local.templateReturnValues = {};
            // Render our view using an renderer encapsulator
            savecontent variable="local.viewContent" {
                cfmodule(
                    template = arguments.template,
                    cbwireComponent = arguments.wire,
                    validationService = variables.validationService,
                    normalizedPath = arguments.normalizedPath,
                    params = arguments.params,
                    returnValues = local.templateReturnValues
                );
            }

            captureTemplateReturnValues( arguments.wire, local.templateReturnValues );

            wire.set_renderedContent( local.viewContent );
            return local.viewContent;
        }       

        return wire.get_renderedContent();
    }

    /**
     * Returns the first outer element from the provided html.
     * "<div x-data=""></div>" returns "div";
     *
     * @return string
     */
    function getOuterElement( html ) {
        local.outerElement = reMatchNoCase( "<[A-Za-z]+\s*", arguments.html ).first();
        local.outerElement = local.outerElement.replaceNoCase( "<", "", "one" );
        return local.outerElement.trim();
    }

    /**
     * Take an incoming rendering and determine the outer component tag.
     * <div>...</div> would return 'div'
     *
     * @rendering string | The rendering to parse.
     *
     * @return string
     */
    function getComponentTag( rendering ){
        var tag = "";
        var regexMatches = reFindNoCase( "^<([a-zA-Z0-9]+)", arguments.rendering.trim(), 1, true );
        if ( regexMatches.match.len() == 2 ) {
            return regexMatches.match[ 2 ];
        }
        throw( type="CBWIREException", message="Cannot determine component tag." );
    }

    /**
     * Validates that the HTML content has a single outer element.
     * Ensures the first and last tags match and that the total number of tags is even.
     *
     * @trimmedHtml string | The trimmed HTML content to validate.
     * @throws ApplicationException | When the HTML does not meet the single outer element criteria.
     */
    function validateSingleOuterElement( trimmedHtml ) {
        return; // Skip until we can find a much faster way to validate a single outer element.

        // Define void elements
        local.voidTags = ["area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"];

        // Trim and remove any extra spaces between tags for accurate matching
        local.cleanHtml = trim(arguments.trimmedHtml).replaceAll("\s+>", ">");

        // Regex to find all tags
        local.tags = reMatch("<\/?[a-z]+[^>]*>", local.cleanHtml);

        // Ensure there is at least one tag
        if (arrayLen(local.tags) == 0) {
            throw("ApplicationException", "Template must contain at least one HTML tag.");
        }

        // Check for single outer element by comparing the first and last tag
        local.firstTag = tags.first().replaceAll("<\/?([a-z]+)[^>]*>", "$1");
        local.lastTag = tags.last().replaceAll("<\/?([a-z]+)[^>]*>", "$1");

        // Check if the first and last tags match and are properly nested
        if ( local.firstTag != local.lastTag ) {
            throw("CBWIRETemplateException", "Template does not have matching outer tags.");
        }

        // Additional check to ensure no other top-level tags are present
        local.depth = 0;
        local.tags.each( function( tag, index ) {
            local.tagName = tag.replaceAll("<\/?([a-z]+)[^>]*>", "$1");

            // Skip depth modification for void elements
            if (arrayFindNoCase(voidTags, local.tagName) && left( arguments.tag, 2) != "</") {
                return;
            }

            if (left( arguments.tag, 2) == "</") {
                depth--;
            } else {
                depth++;
            }
            // If depth returns to zero before last tag, or if depth is not zero after last tag, throw exception
            if (depth == 0 && index != tags.len() || index == tags.len() && depth != 0 ) {
                throw("CBWIRETemplateException", "Template has more than one outer element, or is missing an end tag </element>.");
            }
        });
    }

    /**
     * Normalizes the view path for rendering. This means it will convert the dot notation path 
     * to a slash notation path, check for the existence of .bxm or .cfm files, and ensure the path is correctly formatted.
     *
     * @viewPath string | The dot notation path to the view template to be rendered, without the .cfm extension.
     *
     * @return string
     */
    function normalizeViewPath( required viewPath ) {
        var paths = buildViewPaths( arguments.viewPath );

        if ( paths.normalizedPath contains "cbwire/models/tmp/" ) {
            if ( utilityService.fileExists( paths.fullBxmPath ) ) {
                return "/" & paths.normalizedPath & ".bxm";
            } else {
                return "/" & paths.normalizedPath & ".cfm";
            }
        }

        if ( utilityService.fileExists( paths.fullBxmPath ) ) {
            paths.normalizedPath &= ".bxm";
        } else if ( utilityService.fileExists( paths.fullCfmPath ) ) {
            paths.normalizedPath &= ".cfm";
        } else {
            throw( type="CBWIREException", message="A .bxm or .cfm template could not be found for '#arguments.viewPath#'." );
        }

        if ( left( paths.normalizedPath, 6 ) != "wires/" ) {
            paths.normalizedPath = "wires/" & paths.normalizedPath;
        }
        if ( left( paths.normalizedPath, 1 ) != "/" ) {
            paths.normalizedPath = "/" & paths.normalizedPath;
        }

        return paths.normalizedPath;
    }

    /**
     * Returns the full path to the template file based on the wire and path provided.
     * If the path is a module path (contains '@'), it will resolve to the module's root path.
     * @wire cbwire.models.Component | The wire instance for the component being rendered.
     * @path string | The dot-notation path to the view template.
     * @return string | The full path to the template file.
     */
    function getTemplatePath( required wire, required path ) {
        if ( isModulePath( arguments.path ) ) {
            var moduleRoot = cbwireController.getModuleRootPath( wire._getModuleName() );
            return moduleRoot & ".wires." & wire._getComponentName().listFirst( "@" );
        }

        return "wires." & arguments.path;
    }

    /**
     * Returns true if the path contains a module.
     *
     * @return boolean
     */
    function isModulePath( required viewPath ) {
        return arguments.viewPath contains "@";
    }

    /**
     * Captures the return values from the RendererEncapsulator like cbwire:script and cbwire:assets tags.
     *
     * @return void
     */
    function captureTemplateReturnValues( required wire, required returnValues ) {
        // Parse and track cbwire:script tags
        arguments.returnValues.filter( function( key, value ) {
            return key.findNoCase( "script" );
        } ).each( function( key, value, result ) {
            // Extract the counter from the tag name
            local.counter = key.replaceNoCase( "script", "" );
            // Create script tag id based on compile time id and counter
            local.scriptTagId = wire._getCompileTimeKey() & "-" & local.counter;
            // Track the script tag
            wire._trackScript( local.scriptTagId, value );
        } );

        // Parse and track cbwire:assets tags
        arguments.returnValues.filter( function( key, value ) {
            return key.findNoCase( "assets" );
        } ).each( function( key, value, result ) {
            // Extract the counter from the tag name
            local.counter = key.replaceNoCase( "assets", "" );
            // Create assets tag id based on hash of assets
            local.assetsTagId = hash( value, "MD5" );
            // Track the assets tag
            wire._trackAsset( local.assetsTagId, value );
            local.requestAssets = cbwireController.getRequestAssets();
            local.requestAssets[ local.assetsTagId ] = value;
        } );
    }

    /**
     * Returns the wire:effects attribute contents.
     *
     * @return string
     */
    function generateWireEffectsAttribute( required struct listeners, required struct scripts ) {
        local.effects = {};
        local.listenersAsArray = arguments.listeners.reduce( function( acc, key, value ) {
            acc.append( key );
            return acc;
        }, [] );
        if ( local.listenersAsArray.len() ) {
            local.effects[ "listeners" ] = local.listenersAsArray;
        }
        if ( arguments.scripts.count() ) {
            local.effects[ "scripts" ] = arguments.scripts;
        }
        if ( local.effects.count() ) {
            return encodeAttribute( serializeJson( local.effects ) );
        }
        return "[]";
    }

    /**
     * Encodes a given string for safe usage within an HTML attribute.
     *
     * @value string | The string to be encoded.
     *
     * @return String The encoded string suitable for HTML attribute inclusion.
     */
    function encodeAttribute( required value ) {
        // return arguments.value.replaceNoCase( '"', "&quot;", "all" );
        return encodeForHTMLAttribute(arguments.value);
    }

    /**
     * Inserts Livewire-specific attributes into the given HTML content, ensuring Livewire can manage the component.
     *
     * @html string | The original HTML content to be processed.
     * @snapshotEncoded string | The encoded snapshot data for Livewire's consumption.
     * @id string | The component's unique identifier.
     *
     * @return String The HTML content with Livewire attributes properly inserted.
     */
    private function insertInitialLivewireAttributes( required html, required snapshotEncoded, required id, required listeners, required scripts ) {
        // Trim our html
        arguments.html = arguments.html.trim();
        local.wireEffectsAttribute = generateWireEffectsAttribute( listeners=arguments.listeners, scripts=arguments.scripts );
        // Define the wire attributes to append
        local.wireAttributes = 'wire:snapshot="' & arguments.snapshotEncoded & '" wire:effects="#local.wireEffectsAttribute#" wire:id="#arguments.id#"';
        // Determine our outer element
        local.outerElement = getOuterElement( arguments.html );
        // Find the position of the opening tag
        local.openingTagStart = findNoCase("<" & local.outerElement, arguments.html);
        local.openingTagEnd = find(">", arguments.html, local.openingTagStart);
        // Insert attributes into the opening tag
        if (local.openingTagStart > 0 && local.openingTagEnd > 0) {
            local.openingTag = mid(arguments.html, local.openingTagStart, local.openingTagEnd - local.openingTagStart + 1);
            local.newOpeningTag = replace(local.openingTag, "<" & local.outerElement, "<" & local.outerElement & " " & local.wireAttributes, "one");
            arguments.html = replace(arguments.html, local.openingTag, local.newOpeningTag, "one");
        }

        return arguments.html;
    }

    /**
     * Inserts subsequent Livewire-specific attributes into the given HTML content.
     *
     * @html string | The original HTML content to be processed.
     *
     * @return String The HTML content with Livewire attributes properly inserted.
     */
    private function insertSubsequentLivewireAttributes( required id, required html ) {
        // Trim our html
        arguments.html = arguments.html.trim();
        // Define the wire attributes to append
        local.wireAttributes = "wire:id=""#arguments.id#""";
        // Determine our outer element
        local.outerElement = getOuterElement( arguments.html );
        // Insert attributes into the opening tag
        return arguments.html.reReplaceNoCase( "<" & local.outerElement & "\s*", "<" & local.outerElement & " " & local.wireAttributes & " ", "one" );
    }

    /**
     * Converts a dot-path into .bxm/.cfm absolute paths.
     *
     * @viewPath string | A dot-notation view path like "my.view.component"
     * @return struct { normalizedPath, fullBxmPath, fullCfmPath }
     */
    private function buildViewPaths( required string viewPath ) {
        var normalizedPath = replace( arguments.viewPath, ".", "/", "all" );
        var base = expandPath( "/" & normalizedPath );
        return {
            normalizedPath: normalizedPath,
            fullBxmPath: base & ".bxm",
            fullCfmPath: base & ".cfm"
        };
    }
}