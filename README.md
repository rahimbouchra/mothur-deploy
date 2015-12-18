# Your first Jenkins job

> So you want to bring some applications to the gridcloud eh ... ?

This is a training and demonstration repo for writing -deploy jobs for our build and deploy system at http://ci.sagrid.ac.za

In general we want to make access to the SAGrid build system as open as possible, but manage the rights of anyone who wants to contribute. Since we want to automate as much as possible the delivery of new applications in this distributed environment, we need to have a stepping-stone project which can be personally managed by new users. This is the purpose of this repo.

# Purpose  of this repo

This repository is to demonstrate, with high verbosity, how we expect new applications to be built, tested and deployed. This repository is thus an expression of good practice. As it is tested - like all other `-deploy` repos - with every commit, it is also an expression of the functional state of this good practice.

# How to use this repo

Every jenkins job is connected to specific repo. Let's say you have a new application which you want to port - `myapp`. In order to get started, we expect you to

  1. become a member of this organisation on github.
  1. fork this repo to your own github account (@user/myapp-deploy) and add the relevant files (see below)
  2. for your own repo to this organisation with your app name (@SouthAfricaDigitalScience/myapp-deploy). This will allow us to collaboratively provide suggestions to your new project. Do not edit this repo directly.
  3. We will create the job on jenkins and add the repo to it's configuraiton. When changes are pushed to any of the collaborators, the project will be built and tests run.

# General principles

  1. Try to use the definitive source for the application.
  2. Separate build tests and functional tests
  3. Try to implement as many functional tests as possible - you are building for more than one OS.
  4. Check your dependencies and use the modules which the build system provides for you - do not unnecessarily build dependencies, rather request that the existing dependencies are built according to your satisfaction.

# Contents of the repo

Each deploy job should have at least two executable scripts :

  1. `build.sh`
  2. `check-build.sh`

These define basically two test phases, the **build** and **functional** test phases respectively.

## Build Test Phase

The build phase should do the following things

  1. Set up the build environment variables
  2. Check out the source code
  3. Configure the build
  4. Compile the source into an executable form.
  5. Create a modulefile which loads the dependencies and sets the environment variables needed to execute the application.

The build phase should pass iff the expected libraries and executable files are present. **It is your responsibility to define where these files are, on a case-by-case basis**.

## Functional test phase

Here you are expected to prove that the application actually executes a test payload. You should write a script called `check-buld.sh` which does the following things:

  1. Load the modulefile created by `build.sh`
  2. Execute the application with a predefined input or configuration - **it is your responsibility to provide this**.
  3. Check the validity of the output of the applicaiton - this may vary vastly between applications, but is likely to be something on `stdout` or the presence and content of a particular file.

# But, like, what about ...

If you want to discuss this, or the whole system itself - either ask questions or make proposals for improvement, etc - please start a topic at the [discussion forum](http://discourse.sci-gaia.eu/).

# When things go wrong

If you have a legitimate error, or need support, please [open an issue](../../issues)

# Updates



## Foundation Release 1

Foundation Release 1 was published on 7th December 2015. This provided the basic platform with many tweaks still necessary.
