# iOS Scripts

A set of scripts to manage iOS projects. This scripts are inspired by [this](http://githubengineering.com/scripts-to-rule-them-all/) GitHub engineering blog post and [this](https://github.com/jspahrsummers/objc-build-scripts) repository from [jspahrsummers](https://github.com/jspahrsummers).

This scripts assume that you are using `xcodebuild` to build the project.

**NOTE**: Because of [this](https://github.com/Carthage/Carthage/pull/605) issue in Carthage that hasn't been merged yet we need to use a custom build of Carthage. Also because of [this](https://github.com/Carthage/Carthage/pull/583) issue you need to add your `.p12` in `script/certificates` in your project to be able to sign the `.framework`.

## Installation

To install the scripts into any iOS project you just need to run the install script (no pound intended :wink:)

```
git clone git@github.com:guidomb/ios-scripts.git
cd ios-scripts
./install PATH_TO_IOS_PROJECT_FOLDER
```

The first time you run this script you would probably want to generate .env file that is needed for the scripts to work.

### Project configuration

All the scripts are smart enough to detect if you are using Carthage or Cocoapods and tune their behavior to use the workflow that best suites the underlaying dependency management tool.

#### Git hooks

The install script will prompt you if you want to install git hooks (recommended). At the moment it will install a `pre-push` hook that will run `script/test` before pushing.

## Usage

After installing the scripts in your iOS project you should find a `script` folder with the following scripts

### script/bootstrap

The bootstrap script should be run every time the project is cloned. This scripts checks and installs all the required dependencies required for your project.

By default this script install the basic dependencies for any iOS project to work. It is smart enough the check if you are using Cocoapods or Carthage as the dependency manager.

#### Customize boostrap process

In case you need to install more dependencies or execute some configuration script, the appropriate way to do this is by adding a bootstrap hook. If you create an executable script in `script/script_hooks/bootstrap` that script will be called during the bootstrap process.

### script/build

The build script just builds the project

### script/test

The test script builds and run the tests. If the project has a `.podspec` file is runs the cocoapod linter.

### script/coverage

Generates code coverage data and upload it to [Coveralls](http://coveralls.io). This script is intended to be used in CI. You need to export the environmental variable `COVERALLS_TOKEN`.

Swift code coverage is not supported yet.

### script/update

Updates the project's dependencies using the underlaying dependency management machinery.

### script/cibuild

This script must be run in the CI environment. It bootstraps the project, builds it and run the test.

#### Carthage issues

Thee are some limitation when using Carthage as the dependency management tool in services like
Travis CI.

##### GitHub API rate limit

If you are using Carthage in a machine with a shared public IP, like in Travis CI, you are sharing
the GitHub rate limit quota with the rest of the clients. Because Carthage uses the GitHub API
this could be a problem. That is why is recommended in such environments to use your own access token. The latest stable version of Carthage does not support providing a GitHub access token. This issue has been addressed in [this](https://github.com/Carthage/Carthage/pull/605) pull request but a new stable release hasn't been made yet. That is why we need to use a custom version of Carthage if you want this feature.

To tell Carthage to use your own access token and in order for the bootstrap script to install the custom version of Carthage you need to define the environmental variable `GITHUB_ACCESS_TOKEN`.

Once a new stable release is made there will be no need to install a custom version of Carthage but in your CI machine you will still need to define the `GITHUB_ACCESS_TOKEN`.

##### Code signing certificates

Because Carthage builds all the dependencies and generates a fat `.framework` with binaries for all the possible architectures (iWatch, iPhone, simulator). It needs to sign the artifacts using a code signing certificate. There is an open [issue](https://github.com/Carthage/Carthage/pull/583) to solve this problem but for now you need to provide a `.p12` file with a development certificate and store them in `script/certificates/cibot.p12`. You will also need to provide the passphrase for the certificate in the environmental variable `KEY_PASSWORD`.

## License

**ios-scripts** is available under the Apache 2.0 [license](https://raw.githubusercontent.com/guidomb/ios-scripts/master/LICENSE).

    Copyright 2015 Guido Marucci Blas

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
