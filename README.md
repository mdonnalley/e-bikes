# E-Bikes LWC Storefront

![ebikes-logo](ebikes-logo.png)

This project contains the Salesforce LWC Storefront for E-Bikes, an electric bicycle manufacturer. The E-Bikes e-commerce portal is built using Lightning Web Components and integrated with Salesforce Experience Cloud. This application helps E-Bikes salespeople manage their products and reseller orders using a rich user experience that runs on the Salesforce Platform.

## Setting Up Your Dev Environment

- [Step One: Installing local tools](#optional-tool-installation)
    - [Code formatting](#code-formatting)
    - [Code linting](#code-linting)
    - [Pre-commit hook](#pre-commit-hook)
    - [Lightning Web Component tests](#lightning-web-component-tests)
- [Step Two: Installing E-Bikes into a scratch org](#installing-e-bikes-into-a-scratch-org)

## Step One: Installing Local Tools

The E-Bikes dev team uses several tools and scripts to integrate modern web development best-practices into our Salesforce development process and our continuous integration/continuous deployment processes.

All E-Bikes developers are expected to leverage this common toolset. To comply, you must:

1. Install the Node project dependencies by running `npm install` in a terminal at the root of this project.

A number of helpful scripts are included. For reference, the full list scripts and dependencies and can be found in [package.json](./package.json).

### Code Formatting

[Prettier](https://prettier.io/) is a code formatter used to ensure consistent formatting across your code base. The [.prettierignore](/.prettierignore) and [.prettierrc](/.prettierrc) files provided as part of this repository control the behavior of the Prettier formatter.

### Code Linting

[ESLint](https://eslint.org/) is a popular JavaScript linting tool used to identify stylistic errors and erroneous constructs. The [.eslintignore](/.eslintignore) file is provided as part of this repository to exclude specific files from the linting process in the context of Lightning Web Components development.

### Pre-commit Hook

We use [Husky](https://github.com/typicode/husky) and [lint-staged](https://github.com/okonet/lint-staged) to set up a pre-commit hook that enforces code formatting and linting by running Prettier and ESLint every time you `git commit` changes.

Prettier and ESLint will automatically run every time you commit changes. The commit will fail if linting errors are detected in your changes.

### Lightning Web Component Tests

[Jest](https://jestjs.io/) is the testing library that we use to test our Lightning web components. More precisely, we use a [Jest wrapper library](https://github.com/salesforce/sfdx-lwc-jest) to run LWC tests. These tests are run on your local machine or in CI, not in Salesforce.

## Step Two: Installing E-Bikes into a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:
    - Enable Dev Hub in your Trailhead Playground
    - Install Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

1. Determine if you have already authorized a developer hub org for this project. If you determine you have not already authorized a Dev Hub for this project, authorize one with the alias `DevHubOrg` and set it as your default Dev Hub:

    ```
    sf org login web -d -a DevHubOrg
    ```

1. Create a scratch org with the alias `E-Bikes`:

    ```
    sf org create scratch -d -f config/project-scratch-def.json -a E-Bikes
    ```

1. Push the app to your scratch org:

    ```
    sf project deploy start
    ```

1. Assign the **ebikes** permission set to the default user:

    ```
    sf org assign permset -n ebikes
    ```

1. Assign the **Walkthroughs** permission set to the default user:

    ```
    sf org assign permset -n Walkthroughs
    ```

1. Import sample data:

    ```
    sf data tree import -p ./data/sample-data-plan.json
    ```

1. Publish the Experience Cloud site:

    ```
    sf community publish -n E-Bikes
    ```

1. Deploy metadata for the Experience Cloud guest user profile (not part of the `force-app` package directory):

    ```
    sf project deploy start --metadata-dir=guest-profile-metadata -w 10
    ```

1. Open the scratch org:

    ```
    sf org open
    ```

1. In **Setup**, under **Themes and Branding**, activate the **Lightning Lite** theme.

1. In App Launcher, select the **E-Bikes** app.
