# Installation instructions

This installation guide describes the installation process of openMHA on
Linux (__I.__), Windows (__II.__), and macOS (__III.__) operating systems.

## I. Installation from binary packages on Ubuntu.

First, add the package source with the openMHA installation packages to your system:

In Ubuntu 18.04:

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7D6CDF547DA4ABD
    sudo apt-add-repository 'deb http://apt.hoertech.de bionic universe'

In Ubuntu 16.04:

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7D6CDF547DA4ABD
    sudo apt-add-repository 'deb http://apt.hoertech.de xenial universe'
    sudo apt-get update

Install openMHA:
```
sudo apt-get install openmha
```

After installation, openMHA documentation is found in
`/usr/share/doc/openmha`
and tools for GNU Octave/Matlab in `/usr/lib/openmha/mfiles`.

We provide some examples together with the openMHA.
When using Debian packages, you can find the examples in a separate package,
*openmha-examples*. After installing the openmha-examples package:
```
sudo apt-get install openmha-examples
```
the examples can be found in `/usr/share/openmha/examples`.

NOTE: If you want to use the example files we recommend to make a copy in your
home directory as they are located in a system-wide read-only directory. Some of
the examples may require changes to work with the current audio hardware setup
and need write access to store output.

Algorithm developers interested in implementing their own plugins should also
install the development package __libopenmha-dev__.

For updating openMHA when a new release is available run
```
sudo apt-get install --only-upgrade openmha
```

## II. Windows installer

An openMHA installer for 64 bit Windows can be downloaded from our
Github releases page, https://github.com/HoerTech-gGmbH/openMHA/releases.

On Windows, you may want to add the bin directory to the system PATH.

The installer installs openMHA example setups and some tools. We recommend to
copy the examples folder to a writable location inside your user directory.

You can find the examples folder in the `examples sub-directory` of
the installation directory (e.g. `C:\Program Files\openMHA`). The sub-directories
`mfiles` contains Matlab / Octave files for interacting with openMHA and
documentation is found in `doc`.

## III. macOS installer

An openMHA installer for macOS can be downloaded from our
Github releases page, https://github.com/HoerTech-gGmbH/openMHA/releases.

The installer installs openMHA example setups and some tools. We recommend to
copy the examples folder to a writable location inside your user directory.

On Mac OS, you can find the examples folder in
`/usr/local/share/openmha/examples/`. m-files for interacting with the openMHA
from Matlab or Octave are installed in `/usr/local/lib/openmha/mfiles/`, and
documentation can be found in `/usr/local/doc/openmha/`.
