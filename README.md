# Aeroloop Gazebo

This project provides the necessary Gazebo plugin as well as assets for evaluation of the Betaflight SITL build target.

## Supported Platforms

This project has native support and has been tested with Ubuntu Linux and MacOS. Windows is supported through WSL2.

## Prerequisites

* git
* CMake 3.10.2+
* Gazebo Harmonic (can be installed with `scripts/install_gazebo_harmonic.sh`)

## Setup Guide

1. build BetaflightPlugin with `scripts/build_plugin.sh`

## Launcher

When using Gazebo to test the SITL target it is recommended to use [Betaloop](https://github.com/betaflight/betaloop) to launch the simulation environment. 

## Acknowledgements

This repository is derived from the original [Aeroloop Gazebo](https://github.com/Aeroloop/aeroloop_gazebo) and builds on the work of [wil3](https://github.com/wil3). Thanks to Will for his work in initially creating this project.