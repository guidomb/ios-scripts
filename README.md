# iOS Scripts

A set of scripts to manage iOS projects. This scripts are inspired by [this](http://githubengineering.com/scripts-to-rule-them-all/) GitHub engineering blog post and [this](https://github.com/jspahrsummers/objc-build-scripts) repository from [jspahrsummers](https://github.com/jspahrsummers).

This scripts assume that you are using `xcodebuild` to build the project.

## Installation

To install the scripts into any iOS project you just need to run the install script (no pound intended :wink:)

```
git clone git@github.com:guidomb/ios-scripts.git
cd ios-scripts
./install PATH_TO_IOS_PROJECT_FOLDER
```

The first time you run this script you would probably want to generate .env file that is needed for the scripts to work.

### Batch install

If you have more than one project that is using the build scripts it might be bummer to update your build scripts everytime a new version is released. That is why it is recommended to use the batch install option. All you need to do is add a `.installrc` file (which is git ignored) in the `ios-scripts` root directory. This file should contain full paths to
the projects that are using the build scripts.

For example if you add a `.installrc` file with the following content:

```
/Users/guidomb/Documents/Projects/MyFirstProject
/Users/guidomb/Documents/Projects/MySecondProject
/Users/guidomb/Documents/Projects/MyThirdProject
```

and then run `.install`, the install script will install the builds script for each of the listed project. Which is the same as running

```
./install /Users/guidomb/Documents/Projects/MyFirstProject
./install /Users/guidomb/Documents/Projects/MySecondProject
./install /Users/guidomb/Documents/Projects/MyThirdProject
```

Keep in mind that this only works for projects that have already installed the build scripts.

### Project configuration

All the scripts are smart enough to detect if you are using Carthage or Cocoapods and tune their behavior to use the workflow that best suites the underlaying dependency management tool.

#### Git hooks

The install script will prompt you if you want to install git hooks (recommended). At the moment it will install a `pre-push` hook that will run `script/test` before pushing.

## Usage

All the scripts must be run from the root folder by prefixing the `script` folder. For example if you want to bootstrap your project you should be located at the project's root folder and then run `script/bootstrap`.

After installing the scripts in your iOS project you should find a `script` folder with the following scripts:

### script/bootstrap

The bootstrap script should be run every time the project is cloned. This scripts checks and installs all the required dependencies required for your project.

By default this script install the basic dependencies for any iOS project to work. It is smart enough the check if you are using Cocoapods or Carthage as the dependency manager.

#### Customize bootstrap process

In case you need to install more dependencies or execute some configuration script, the appropriate way to do this is by adding a bootstrap hook. If you create an executable script in `script/script_hooks/bootstrap` that script will be called during the bootstrap process.

#### Build configuration for Travis CI

If you are using Travis CI to build and test your project you only need to tell travis to
execute `script/cibuild`

```yaml
language: objective-c
osx_image: xcode6.4
script: script/cibuild
branches:
  only:
  - master
```

Remember to export the required environmental variables using the `travis` command line tool

```
travis encrypt GITHUB_ACCESS_TOKEN=your-access-token --add env.global
travis encrypt KEY_PASSWORD=dev-certificate-passphrase --add env.global
travis encrypt COVERALLS_TOKEN=coveralls-repo-token --add env.global
```

#### Build configuration for Circle CI

If you are using Circle CI to build and test your project you only need to tell Circle to
execute `script/cibuild`

```yaml
machine:
  xcode:
    version: "6.3.1"
test:
  override:
    - script/cibuild
```

Remember to export the required environmental variables in the project's setting from the Circle CI web tool.


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
this could be a problem. That is why is recommended in such environments to use your own access token.

To tell Carthage to use your own access token and in order for the bootstrap script to install the custom version of Carthage you need to define the environmental variable `GITHUB_ACCESS_TOKEN`.

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
