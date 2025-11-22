# GitHub Copilot Instructions for CBWIRE

## Project Overview

CBWIRE is a ColdBox module that enables developers to build modern, reactive, single-page CFML applications without writing extensive JavaScript or building backend APIs. It's inspired by Laravel Livewire and brings similar reactive component functionality to the CFML ecosystem.

## Language and Framework

- **Primary Language**: CFML (ColdFusion Markup Language)
- **Framework**: ColdBox (CFML MVC framework)
- **File Extensions**: `.cfc` (ColdFusion Component), `.cfm` (ColdFusion Markup)
- **CFML Engines Supported**: Lucee 5+, Adobe ColdFusion 2021+, Adobe ColdFusion 2023+

## Code Style and Conventions

### General CFML Conventions

1. **Component Syntax**: Use script-based component syntax (not tag-based)
2. **Function Casing**:
   - Built-in functions: Follow CFDocs casing conventions
   - User-defined functions: camelCase
3. **Indentation**: Use tabs (4 spaces equivalent)
4. **Line Length**: Maximum 120 characters
5. **Quotes**: Use double quotes for strings
6. **Struct Separator**: Use ` : ` (space-colon-space) for struct key-value pairs

### Code Formatting

This project uses `commandbox-cfformat` for automatic code formatting. The configuration is in `.cfformat.json`. Key formatting rules:

- Tab indentation (actual tab characters with display width of 4 spaces)
- Double quotes for strings
- Padding inside parentheses, brackets, and struct literals
- Arrays/structs split to multiple lines when > 40 characters or > 2 elements
- Binary operators should have padding
- Block spacing: spaced between keywords and blocks

To format code:

```bash
box run-script format
```

To check formatting:

```bash
box run-script format:check
```

### Component Structure

Components should follow this general structure:

```cfml
component {
    // Properties at the top
    property name="propertyName" type="string";
    
    // Constructor/init method
    function init() {
        return this;
    }
    
    // Public methods
    public function publicMethod() {
        // implementation
    }
    
    // Private methods
    private function privateMethod() {
        // implementation
    }
}
```

## Project Structure

- `/models/` - Core CBWIRE models and components
  - `ComponentLoader.cfc` - Loads wire components
  - `preprocessor/` - Template preprocessing components
  - `SingleFileComponentBuilder.cfc` - Builds single-file components
- `/handlers/` - HTTP request handlers
- `/interceptors/` - ColdBox interceptors for CBWIRE lifecycle
- `/views/` - View templates
- `/helpers/` - Helper functions and utilities
- `/test-harness/` - Testing application
  - `/tests/` - TestBox test suites
  - `/wires/` - Example wire components for testing
- `/includes/` - Static assets (CSS, JS)
- `ModuleConfig.cfc` - Module configuration and settings

## Build and Test

### Package Manager

This project uses **CommandBox** as its package manager and CLI tool.

### Installing Dependencies

```bash
# Install main dependencies
box install

# Install test harness dependencies
cd test-harness && box install
```

### Running Tests

Tests use **TestBox** framework and run on multiple CFML engines:

```bash
# Start test server (from test-harness directory)
cd test-harness
box server start

# Run tests
box testbox run
```

The CI runs tests against:

- Lucee 5+
- Adobe ColdFusion 2021+
- Adobe ColdFusion 2023+

### Building Documentation

```bash
box run-script build:docs
```

## Development Guidelines

### Creating Wire Components

Wire components are reactive CFML components stored in `/wires/` (configurable). They should:

1. Extend the base CBWIRE component
2. Define data properties that will be reactive
3. Implement action methods that can be called from the frontend
4. Use lifecycle methods when needed (mount, hydrate, etc.)

Example wire component:

```cfml
component extends="cbwire.models.Component" {
    
    data = {
        "message": "Hello World"
    };
    
    function updateMessage( newMessage ) {
        data.message = newMessage;
    }
}
```

### Adding New Features

1. Create models in `/models/` if adding core functionality
2. Add tests in `/test-harness/tests/specs/`
3. Update documentation if needed
4. Run tests locally before committing
5. Format code with `box run-script format`

### Testing Requirements

- Write TestBox specs for new functionality
- Place specs in `/test-harness/tests/specs/`
- Follow existing test patterns (BDD style with `describe()` and `it()`)
- Ensure tests pass on all supported CFML engines
- Test files should end with `Spec.cfc`

Example test structure:

```cfml
component extends="coldbox.system.testing.BaseTestCase" {
    
    function run() {
        describe("Feature Name", function() {
            it("should do something specific", function() {
                expect( result ).toBe( expected );
            });
        });
    }
}
```

## Configuration

### Module Settings

Module settings are defined in `ModuleConfig.cfc`:

- `autoInjectAssets` - Auto-include CSS/JS assets (default: `true`)
- `moduleRootPath` - Physical path to module
- `moduleRootURL` - URL to module root (default: `"/modules/cbwire"`)
- `throwOnMissingSetterMethod` - Throw exception on missing setters (default: `false`)
- `wiresLocation` - Folder name for wire components (default: `"wires"`)
- `trimStringValues` - Trim string properties (default: `false`)
- `showProgressBar` - Enable progress bar with wire:navigate (default: `true`)
- `progressBarColor` - Progress bar color (default: `"#2299dd"`)

## Dependencies

- **cbcsrf**: CSRF protection module (required dependency)
- See `box.json` for current version constraints

## Common Patterns

### Dependency Injection

Use ColdBox's WireBox for dependency injection:

```cfml
property name="serviceName" inject="ServiceName@module";
```

### Settings Access

Access module settings:

```cfml
variables.settings = getModuleSettings( "cbwire" );
```

### Route Definitions

Routes are defined in `ModuleConfig.cfc` under the `routes` array.

## Documentation

- Official Docs: https://cbwire.ortusbooks.com/
- Repository: https://github.com/coldbox-modules/cbwire
- Issue Tracker: https://github.com/coldbox-modules/cbwire/issues

## Additional Notes

- This is a module for ColdBox, not a standalone application
- The project includes a test-harness which is a full ColdBox application for testing
- JavaScript assets are in `/includes/js/` and are part of the Livewire integration
- The project uses GitHub Actions for CI/CD (see `.github/workflows/`)
- Semantic versioning is followed
- Code is published to ForgeBox (CFML package registry)
