# CBWIRE

[![cbwire CI](https://github.com/coldbox-modules/cbwire/actions/workflows/ci.yml/badge.svg?branch=development)](https://github.com/coldbox-modules/cbwire/actions/workflows/ci.yml)

CBWIRE is a ColdBox module that makes building reactive, dynamic, and modern interfaces delightfully easy without leaving the comfort of CFML.

<div align="center">
	<img src="https://raw.githubusercontent.com/coldbox-modules/cbwire/development/logo.png">
</div>

## Short Pitch

Build reactive apps easily using CFML and less JavaScript!

## Longer Pitch

Building modern CFML apps is a pain. ColdBox makes creating server-side apps easy, but what about the client-side? Front-end JavaScript frameworks like Vue and React are powerful, yet they also introduce complexity and a significant learning curve when creating our apps.

What if you could create apps that look and feel like your Vue and React web apps but are written with CFML. Impossible, you say? Nay, we say!

Introducing **CBWIRE**: Power-up your CFML!

## Requirements

-   Adobe CF 2018+ or Lucee 5+
-   ColdBox 6+

## Installation

Install [CommandBox](https://www.ortussolutions.com/products/commandbox), then from your terminal, run:

```bash
box install cbwire@be
```

## Examples

Included in this repo is an app where you can experience and see code examples covering all the features of CBWIRE.

Just run the following from the `test-harness` directory:

```
box install && cd .. && box server start
```

Then visit:

http://localhost:60299/


## Contributing

We love PRs! Please create a ticket using the [ Issue Tracker](https://github.com/coldbox-modules/cbwire/issues) before submitting a PR.

## Test Harness

There is a test harness application included in this repo.

To start the test harness:

```
cd test-harness
box install
box server start
```

This will start the test harness using a random port selected by CommandBox. For example, if the random port selected is 60299, you can run the test suite using http://127.0.0.1:60299/tests.

## License

Apache License 2.0

## Credits

CBWIRE wouldn't exist without **Caleb Porzio** ( creator of Livewire and Alpine.js ) and the PHP community.

CBWIRE is a port of Livewire's functionality to ColdBox and CFML, with some additional goodies sprinkled in.

The CBWIRE module for ColdBox is written and maintained by [Grant Copley](https://twitter.com/grantcopley), [Luis Majano](https://twitter.com/lmajano), and [Ortus Solutions](https://www.ortussolutions.com/).

## Project Support

We love PRs!

If CBWIRE makes you happy, please consider becoming a [Patreon supporter](https://www.patreon.com/ortussolutions).

## Resources

-   Docmentation: https://cbwire.ortusbooks.com
-   API Docs: https://apidocs.ortussolutions.com/#/coldbox-modules/cbwire/
-   GitHub Repository: https://github.com/coldbox-modules/cbwire
-   Issue Tracker: https://github.com/coldbox-modules/cbwire/issues
-   Task List Demo: https://github.com/grantcopley/cbwire-task-list-demo
-   Up and Running Screencast: https://cfcasts.com/series/ortus-single-video-series/videos/up-and-running-with-cbwire
-   Into The Box 2021 Presentation: https://cfcasts.com/series/into-the-box-2021/videos/cbwire-coldbox-+-livewire-grant-copley
-   Ortus Webinar 2022: https://cfcasts.com/series/ortus-webinars-2022/videos/grant-copley-on-cbwire-+-alpine_js
