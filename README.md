# iOS Scripts

[![Build Status](https://travis-ci.org/guidomb/ios-scripts.svg)](https://travis-ci.org/guidomb/ios-scripts)

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

### Carthage users

If you use Carthage you can specify the required carthage version by your project in `script/.env` by setting the `REQUIRED_CARTHAGE_VERSION` variable.

All build script will check if the Carthage version matches the required version. If that is not the case the scripts will fail.

When running `script/bootstrap` you can force the script to install the desired version of Carthage (pointed by `REQUIRED_CARTHAGE_VERSION`) using the environmental variable `FORCE_CARTHAGE_VERSION` or not updating Carthage
(and fail) if the installed version does not match the desired one by using
`NO_CARTHAGE_UPDATE`.

If you are running on Travis CI (or any other CI services that already has Carthage installed) you probably want to use `FORCE_CARTHAGE_VERSION`.

#### Carthage cache

If [CarthageCache](https://github.com/guidomb/carthage_cache) is installed
using Bundler, then the bootstrap and update script will try to use the cache. You can disable carthage cache for a specific run by setting the
`DISABLE_CARTHAGE_CACHE` environmental variable.

The bootstrap script will also try to generate the `.carthage_cache.yml`
if it doesn't exist. Keep in mind that `.carthage_cache.yml` should be
git ignored. You can avoid generating the configuration file by setting
the `DISABLE_CARTHAGE_CACHE_CONFIG` environmental variable.

In a CI environment, like Travis CI, it is recommended to configure
carthage cache using environmental variables. If you want to change the
bucket name you can set the `CARTHAGE_CACHE_BUCKET_NAME` variable. Which
will pass the value of that variable to carthage cache's `--bucket-name`
flag.

#### Code signing certificates

Because Carthage builds all the dependencies and generates a fat `.framework` with binaries for all the possible architectures (iWatch, iPhone, simulator). It needs to sign the artifacts using a code signing certificate. Code signing is not necessary if the dependency is properly configured not to code sign for
simulator architectures. But some dependency are not properly configured and you
will need to code sign even for simulator architectures.

In such case you need to provide a `.p12` file with a development certificate and store them in `script/certificates/cibot.p12`. You will also need to provide the passphrase for the certificate in the environmental variable `KEY_PASSWORD`.

#### GitHub API rate limit

If you are using Carthage in a machine with a shared public IP, like in Travis CI, you are sharing
the GitHub rate limit quota with the rest of the clients. Because Carthage uses the GitHub API
this could be a problem. That is why is recommended in such environments to use your own access token.

To tell Carthage to use your own access token and in order for the bootstrap script to install the custom version of Carthage you need to define the environmental variable `GITHUB_ACCESS_TOKEN`.

### Project configuration

All the scripts are smart enough to detect if you are using Carthage or Cocoapods and tune their behavior to use the workflow that best suites the underlaying dependency management tool.

#### Project schemes

Both the `test` and `build` scripts need to know the schemes that are going to be built by `xcodebuild`. The scripts try to automatically infer the schemes by parsing the output from `xcodebuild -list` but sometimes it may not work (most likely when using Cocoapods) or you may want to customize it. You can do so by changing the `schemes` function in `script/script_hooks/schemes`.

Lets say you want to build and test only for `MyScheme1` and `MyScheme2`. Then you must implement the `schemes` function like this:

```bash
schemes ()
{
  echo "MyScheme1 MyScheme2"
}
```

Or you can override this by defining the variable `SCHEME` like this

```bash
SCHEME=MyScheme ./script/cibuild
```

#### xcodebuild `-destination` parameter

In order to run your test, `xcodebuild` needs an extra parameter to specify where.
The scripts pick the correct destination using the scheme name using the following pattern (case insensitive)

* `*-iOS`: for iOS
* `*-OSX`: for OSX targets
> If the scheme name does not match any of these, iOS destination will be used by default.

These are the default values for each platform

* iOS: `'platform=iOS Simulator,name=iPhone 6,OS=latest'`
* OSX: `'platform=OS X'`

For iOS you can change the name of the simulator or the OS version it should emulate.
To use a different emulator just define the variable `IOS_DESTINATION_SIMULATOR_NAME` with the name of the simulator to use

```bash
IOS_DESTINATION_SIMULATOR_NAME="iPhone 6s Plus" script/cibuild
```
> For all possible names, just run `xcrun simctl list devicetypes`

To use a different OS just define the variable `IOS_DESTINATION_VERSION` with the OS version to use

```bash
IOS_DESTINATION_VERSION="9.0" script/cibuild
```

#### Git hooks

The install script will prompt you if you want to install git hooks (recommended). At the moment it will install a `pre-push` hook that will run `script/test` before pushing.

## Usage

All the scripts must be run from the root folder by prefixing the `script` folder. For example if you want to bootstrap your project you should be located at the project's root folder and then run `script/bootstrap`.

After installing the scripts in your iOS project you should find a `script` folder with the following scripts:

### script/bootstrap

The bootstrap script should be run every time the project is cloned. This scripts checks and installs all the required dependencies required for your project.

By default this script install the basic dependencies for any iOS project to work. It is smart enough the check if you are using Cocoapods or Carthage as the dependency manager.

You can skip updating brew formulas by defining `SKIP_BREW_FORMULAS_UPDATE` environmental variable. For example `SKIP_BREW_FORMULAS_UPDATE=1 script/bootstrap`. Which is useful when you are running the bootstrap script
several time to add or test new functionality.

#### Customize bootstrap process

In case you need to install more dependencies or execute some configuration script, the appropriate way to do this is by adding a bootstrap hook. If you create an executable script in `script/script_hooks/bootstrap` that script will be called during the bootstrap process.

You can disable bootstrap hooks by defining `DISABLE_BOOTSTRAP_HOOKS`
environmental variable.

If your hooks need to know if they are running on CI they can check if the
environmental `$RUNNING_ON_CI` is defined.

#### Build configuration for Travis CI

If you are using Travis CI to build and test your project you only need to tell travis to
execute `script/cibuild`

```yaml
language: objective-c
osx_image: xcode7.2
before_install:
- gem install bundler
script:
- REPO_SLUG="$TRAVIS_REPO_SLUG" PULL_REQUEST="$TRAVIS_PULL_REQUEST" FORCE_CARTHAGE_VERSION=true script/cibuild
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

### script/build

The build script just builds the project

### script/test

The test script builds and run the tests.

  * If the project has a `.swiftlint.yml` file the the [Swift linter](https://github.com/realm/SwiftLint) is run.
  * If the project uses [linterbot](https://github.com/guidomb/linterbot), the `script/test` is run on CI for a pull request and `swiftlint` is avaliable then the `linterbot` will be executed.
  * If the project has a `.podspec` file the Cocoapods podspec linter is run.

### script/coverage

Generates code coverage data and upload it to [Coveralls](http://coveralls.io). This script is intended to be used in CI. You need to export the environmental variable `COVERALLS_TOKEN`.

Swift code coverage is not supported yet.

### script/update

Updates the project's dependencies using the underlaying dependency management machinery.

### script/cibuild

This script must be run in the CI environment. It bootstraps the project, builds it and run the test.

## script/buildtime

This script builds the project and prints the files by their build time sorted from the slowest to the fastest. It
only prints that takes more than 9ms to build.

#### Configure SwiftLint run script for CI

If your project is using [SwiftLint](https://github.com/realm/SwiftLint) it is recommended to configure the run script as follow instead of how it is explained in the SwiftLint docs.

```bash
if [ ! -z "$RUNNING_ON_CI" ]
then
    echo "SwiftLint run script has been disabled"
    exit 0
fi

if which swiftlint >/dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

This allows disabling the run script when running on CI and running the linter twice.

#### Configure linterbot for CI

If your project is using [SwiftLint](https://github.com/realm/SwiftLint) and [linterbot](https://github.com/guidomb/linterbot) then you need to add the following environmental variables when running `script/cibuild`:

  * `REPO_SLUG`: The GitHub repository slug, like `guidomb/ios-scripts`.
  * `PULL_REQUEST`: The pull request number to be analyzed if the current build was triggered by a pull request or `false` otherwise.

Keep in mind that the linterbot also uses the enviromental variable `GITHUB_ACCESS_TOKEN` (which is also used by Carthage). The GitHub user associated with that token should have write access to the repository and is the user that will be used to comment on every linter validation in the pull request.

### General configuration variables

 * `VERBOSE` if you set the `VERBOSE` environmental with a value the scripts will print more information.

### Common utility scripts

Common utility scripts or sets of functions that are useful but are not tied to a particular build script are available in `script/common`.

  * `script/common/install_carthage`: Allows to install a specific version of Carthage.
  * `script/common/install_swiftlint`: Allows to install a specific version of SwiftLint.

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
