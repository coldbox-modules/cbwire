# cbwire ( ColdBox + Livewire)

[![cbwire CI](https://github.com/coldbox-modules/cbwire/actions/workflows/ci.yml/badge.svg?branch=development)](https://github.com/coldbox-modules/cbwire/actions/workflows/ci.yml)

cbwire is a ColdBox module that makes building reactive, dynamic, and modern interfaces delightfully easy without leaving the comfort of CFML.

<div align="center">
	<img src="https://user-images.githubusercontent.com/1197835/136311530-a9647105-09b8-4c49-8ea0-85cb73714de2.png">
</div>

## Short Pitch

Build reactive apps easily using CFML and less JavaScript!

## Longer Pitch

Building modern CFML apps is a pain. ColdBox makes creating server-side apps easy, but what about the client-side? Front-end JavaScript frameworks like Vue and React are powerful, yet they also introduce complexity and a significant learning curve when creating our apps.

What if you could create apps that look and feel like your Vue and React web apps but are written with CFML. Impossible, you say? Nay, we say!

Introducing **cbwire**: Power-up your CFML!

## Requirements

-   Adobe CF 2018+ or Lucee 5+
-   ColdBox 6+

## Task List Demo

You can see cbwire in action: [https://github.com/grantcopley/cbwire-task-list-demo](https://github.com/grantcopley/cbwire-task-list-demo)

## Installation

Install [CommandBox](https://www.ortussolutions.com/products/commandbox), then from your terminal, run:

```bash
box install cbwire@be
```

## Contributing

### Test Harness

There is a test harness application included in this repo that is used for testing cbwire's functionality.

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

cbwire wouldn't exist without **Caleb Porzio** ( creator of Livewire and Alpine.js ) and the PHP community.

cbwire is a port of Livewire's functionality to ColdBox and CFML, with some additional goodies sprinkled in.

The cbwire module for ColdBox is written and maintained by [Grant Copley](https://twitter.com/grantcopley), [Luis Majano](https://twitter.com/lmajano), and [Ortus Solutions](https://www.ortussolutions.com/).

## Project Support

We love PRs!

If cbwire makes you happy, please consider becoming a [Patreon supporter](https://www.patreon.com/ortussolutions).

## Resources

-   Docmentation: https://cbwire.ortusbooks.com
-   GitHub Repository: https://github.com/coldbox-modules/cbwire
-   Jira Issue Tracker: https://ortussolutions.atlassian.net/jira/software/c/projects/CBWIRE/boards/109
-   Task List Demo: https://github.com/grantcopley/cbwire-task-list-demo
-   Up and Running Screencast: https://cfcasts.com/series/ortus-single-video-series/videos/up-and-running-with-cbwire
-   Into The Box 2021 Presentation: https://cfcasts.com/series/into-the-box-2021/videos/cbwire-coldbox-+-livewire-grant-copley
-   Ortus Webinar 2022: https://cfcasts.com/series/ortus-webinars-2022/videos/grant-copley-on-cbwire-+-alpine_js
