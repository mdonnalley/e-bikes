# E-Bikes LWC Storefront

![ebikes-logo](ebikes-logo.png)

This project contains the Salesforce LWC Storefront for E-Bikes, an electric bicycle manufacturer. The E-Bikes e-commerce portal is built using Lightning Web Components and integrated with Salesforce Experience Cloud. This application helps E-Bikes salespeople manage their products and reseller orders using a rich user experience that runs on the Salesforce Platform.

## Setting Up Your Dev Environment

- [Step One: Install Local Tools](#step-one-install-local-tools)
    - [Code formatting](#code-formatting)
    - [Code linting](#code-linting)
    - [Pre-commit hook](#pre-commit-hook)
    - [Lightning Web Component tests](#lightning-web-component-tests)
- [Step Two: Build a Development Environment](#step-two-build-a-development-environment)

## Step One: Install Local Tools

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

## Step Two: Build a Development Environment

1. Decide if you want to use an existing Dev Hub for this project or authenticate a new one.
    - If using an existing Dev Hub, set it as the default for this project:

        ```
        sf config set target-dev-hub=<Your_DevHub_Username_or_Alias>
        ```

    - If using a new Dev Hub, authorize it with the alias `DevHubOrg` and set it as your default Dev Hub:
        ```
        sf org login web -d -a DevHubOrg
        ```

2. Create a default scratch org with the alias `E-Bikes`:

3. Deploy the project source.

4. Assign BOTH the `ebikes` and `Walkthroughs` permission sets to the default user.

5. Import sample data using this command:

    ```
    sf data tree import -p ./data/sample-data-plan.json --json
    ```

6. Publish the Experience Cloud site using this command:

    ```
    sf community publish -n E-Bikes --json
    ```

7. Deploy Experience Cloud guest metadata using this command:

    ```
    sf project deploy start --metadata-dir=guest-profile-metadata -w 10 --json
    ```

8. After opening your scratch org, go to **Setup**, under **Themes and Branding**, and activate the **Lightning Lite** theme.

9. To explore the app, open the App Launcher and select the **E-Bikes** app.
