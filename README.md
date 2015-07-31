# iOS Scripts

A set of scripts to manage iOS projects. This scripts are inspired by [this](http://githubengineering.com/scripts-to-rule-them-all/) GitHub engineering blog post and [this](https://github.com/jspahrsummers/objc-build-scripts) repository from [jspahrsummers](https://github.com/jspahrsummers).

## Installation

To install the scripts into any iOS project you just need to run the install script (no pound intended :wink:)

```
git clone git@github.com:guidomb/ios-scripts.git
cd ios-scripts
./install PATH_TO_IOS_PROJECT_FOLDER
```

The first time you run this script you would probably want to generate .env file that is needed for the scripts
to work.

## Usage

After installing the scripts in your iOS project you should find a `script` folder with the following scripts

### script/bootstrap

The bootstrap script should be run every time the project is cloned. This scripts checks and installs all the required dependencies required for your project.

By default this script install the basic dependencies for any iOS project to work. It is smart enough the check if you are using Cocoapods or Carthage as the dependency manager.

In case you need to install more dependencies or execute some configuration script, the appropiate way to do this is by adding a bootstrap hook. If you create an executable script in `script/script_hooks/bootstrap` that script will be called during the bootstrap process.

### script/build

The build script just builds the project

### script/test

The test script builds and run the tests. If the project has a `.podspec` file is runs the cocoapod linter.

### script/coverage

Generates code coverage data and upload it to [Coveralls](http://coveralls.io). This script is intended to be used in CI.

### script/update

Updates the project's dependencies using the underlaying dependency management machinery.

### script/cibuild

This script must be run in the CI environment. It bootstraps the project, builds it and run the test.

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
