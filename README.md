_Acknowledgements: to Ian K for once upon a time enthusiastically introducing me to Emacs, something I always try to pass on to my non-Emacs using friends and colleagues._

Table of Contents
=================

   * [Table of Contents](#table-of-contents)
   * [Overview](#overview)
   * [Installing pre-requisites](#installing-pre-requisites)
      * [Installing pre-requisites for the core packages](#installing-pre-requisites-for-the-core-packages)
         * [CMake-IDE/RTags](#cmake-idertags)
            * [CMake](#cmake)
            * [Clang/LLVM](#clangllvm)
            * [RTags/rdm (RTags daemon)](#rtagsrdm-rtags-daemon)
         * [Ivy](#ivy)
      * [Installing pre-requisites for the convenience packages](#installing-pre-requisites-for-the-convenience-packages)
         * [Smart-mode-line](#smart-mode-line)
         * [PlantUML-mode](#plantuml-mode)
   * [Installing Emacs 25](#installing-emacs-25)
   * [Setting up Emacs](#setting-up-emacs)

# Overview

**Recently tested for Emacs 25.3.2, at Ubuntu Xenial (16.04)**

My Emacs setup is mainly targeted for C++ development in CMake projects under Git version control.

The core packages of my setup are:

- [`cmake-ide`](https://github.com/atilaneves/cmake-ide) with [`rtags`](https://github.com/Andersbakken/rtags) for IDE-like features on Emacs for CMake projects.
  - Where `rtags` fall back on clang as C++ parser.
  - Using [`flycheck`](https://github.com/flycheck/flycheck) for on-the-fly syntax checking.
  - Combined with [`company-mode`](http://company-mode.github.io/) and [`irony-mode`](https://github.com/Sarcasm/irony-mode) (and clang parsing) for code completion.
- [`magit`](https://magit.vc/) for any kind of Git interaction. `magit` is such an awesome Git client that I even recommend my non-Emacs-colleagues to turn to Emacs/`magit` solely for using Git (sneakily allowing to possibly tempt them to get into all other, never-ending additional upsides of using Emacs).
- [`ivy`](https://github.com/abo-abo/swiper) for minibuffer code completion.

Some other convenience packages worth mentioning:

- [`smart-mode-line`](https://github.com/Malabarba/smart-mode-line) with a powerline theme for a nice Emacs mode-line.
  - The `smart-mode-line-powerline-theme` requires you to install [Powerline fonts](https://github.com/powerline/fonts).
- [`plantuml-mode`](https://github.com/skuro/plantuml-mode) major mode for editing and swiftly pre-viewing PlantUML diagrams.
  - Naturally requires the `plantuml.jar`.

Finally, I use [`cask`](http://cask.readthedocs.io/en/latest/index.html) to manage package dependencies for my Emacs configuration.

# Installing pre-requisites

I wont even mention `git`.

## Installing pre-requisites for the core packages

### CMake-IDE/RTags

Before we start, resync APT package index files:

```
$ sudo apt-get update
```

#### CMake

Make sure you have CMake installed:

```
$ cmake --version
```

If you have none installed (or if it's for some reason hideously old, < CMake 2.8), get it e.g. directly from Ubuntu; at the time of writing this should install CMake 3.5.1, which suffices for RTags (even if it's somewhat ancient as compared to latest release 3.10):

```
$ sudo apt-get install cmake
```

#### Clang/LLVM

Next up, we install clang and llvm. For Ubuntu Xenial, at the time of writing, `clang-4.0`/`llvm-4.0` are appropriate candidates (limiting ourselves to a stable branch; if you want e.g. 5.0 knock yourself out!):

```
$ sudo apt-get install clang-4.0 llvm-4.0 libclang-4.0-dev clang-format-4.0
```

You might also want to update to use `clang-4.0` to provide for `/usr/bin/clang` (which may be entirely missing now):

```
$ sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-4.0 100 \
--slave /usr/bin/clang++ clang++ /usr/bin/clang++-4.0 \
--slave /usr/bin/clang-check clang-check /usr/bin/clang-check-4.0 \
--slave /usr/bin/clang-query clang-query /usr/bin/clang-query-4.0 \
--slave /usr/bin/clang-rename clang-rename /usr/bin/clang-rename-4.0 \
--slave /usr/bin/clang-format clang-format /usr/bin/clang-format-4.0

```

Otherwise Emacs might prompt you that `clang` (or e.g. `clang-format`) cannot be found.

#### RTags/rdm (RTags daemon)

Clone the RTags project; I chose to clone it into my `~/opensource` folder:

```
$ cd ~/opensource
$ git clone --recursive https://github.com/Andersbakken/rtags.git
```

Build RTags:

```
# in ~/opensource
$ cd rtags
$ mkdir build
$ cd build
$ cmake ..
$ make
$ sudo make install
```

### Ivy

`ivy` is, but to point out some specifics, I use `ivy` for `swiper` in-buffer search and for the `counsel` (`ivy`-enhanced) Emacs commands. For the latter, most frequently `counsel-git` (find tracked file in current repo), `counsel-git-grep` and `counsel-ag`. The latter make use of [`ag` - The Silver Searcher](https://github.com/ggreer/the_silver_searcher), and is useful when wanting to search through only parts of a repository, limited to a folder and all tracked file therein (recursively for all sub-folders).

To use `counsel-ag`, install `ag`:

```
$ sudo apt-get install silversearcher-ag
```

## Installing pre-requisites for the convenience packages

### Smart-mode-line

For the `smart-mode-line-powerline-theme`, install [Powerline fonts](https://github.com/powerline/fonts):

```
# I generally put all open source repos under ~/opensource
$ cd ~/opensource

# clone
$ git clone https://github.com/powerline/fonts.git --depth=1

# install
$ cd fonts
$ ./install.sh
```

### PlantUML-mode

Download the latest [`plantuml.jar`](http://plantuml.com/download). I usually place mine in `~/opensource/plantuml/`.


# Installing Emacs 25

In case you're not already running an Emacs 25 version:

```
$ emacs --version # 25?
```

Then install it. Emacs 25 is readily available via the APT package manager for Ubuntu:

```
$ sudo apt-get install emacs25
```

Ascertain, after installation, that you're not using an older version:

```
$ emacs --version # 25.X.Y?
```

I usually make sure to remove any older versions; packages `emacsXY`/`emacsXY-...` which is not `emacs25`. To identify such packages, study the output of:

```
$ dpkg --get-selections | grep emacs
```

Or just tab-complete `sudo apt-get remove ...`.

To remove said packages:

```
$ sudo apt-get remove --purge emacsXY
$ sudo apt-get remove --purge emacsXY-...
# et. cetera.
```

# Installing and setting up Cask

Before installing Cask, make sure that you `EMACS` environment variable point to the same Emacs version as your `emacs` command.

```
$ emacs --version

# this must be the same version
$ echo $EMACS
```

Is this is not a match, re-try in a new terminal window.

## Installing cask

To install Cask, run the follwing command:

```
$ curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
```

This should install Cask in `~/.cask/`. Make sure to follow the on-success prompt to add the `cask` binary to your path:

```
# e.g. in your .bashrc, or whatever shell you're using
export PATH="/home/dfri/.cask/bin:$PATH"
```

## Setting up a Cask project file for your Emacs configuration

Copy the `/.emacs.d/Cask` file of this repo to you local `~/.emacs.d/`. If the `~/.emacs.d/` folder is missing, create it or simply start/close `emacs` once to let it be created automatically.

```
```

Moreover, create an `init.el` file in your local `~/.emacs.d/` folder with the following content:

```
$ cd ~/.emacs.d/
$ touch init.el

;; Add this into the init.el file (which is otherwise empty)
(package-initialize)
(require 'cask "~/.cask/cask.el")
(cask-initialize)

```

and thereafter install all dependencies:

```
$ cask install
```

# Setting up Emacs

Replace the dummy `init.el` file from the step above with the `/.emacs.d/init.el` file of this repo.

You should be good to go!


# Starting the RDM server

TODO: describe how to use e.g. `tmux` to setup an automatic `rdm` startup prior to launching Emacs.