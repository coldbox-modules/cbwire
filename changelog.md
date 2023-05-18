# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----
## [3.0.0] => Upcoming

#### Added
- [CBWIRE-98](https://github.com/coldbox-modules/cbwire/issues/98)
Automatically cache computed properties in the cache proxy for better performance

- [CBWIRE-99](https://github.com/coldbox-modules/cbwire/issues/99)
Update setting 'useComputedPropertiesProxy' to default to true

#### Fixed
- [CBWIRE-100](https://github.com/coldbox-modules/cbwire/issues/100)
Fix ability to locate Wires using full path such as appMapping.wires.SomeComponent.

- [CBWIRE-97](https://github.com/coldbox-modules/cbwire/issues/97)
Empty string and null values are not being properly passed to Livewire.


## [2.0.0] => Upcoming

#### Improvement

- [CBWIRE-25]( https://github.com/coldbox-modules/cbwire/issues/25 ) Reject incoming XHR requests if 'X-Livewire' HTTP Header is not present

## [1.0.0] => 2021-APR

### Added

* First module iteration
* 