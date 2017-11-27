

Table of Contents
=================

   * [How to setup dfrib's basic Emacs environment](#how-to-setup-dfribs-basic-emacs-environment)
      * [Background](#background)
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
   * [Installing and setting up Cask](#installing-and-setting-up-cask)
      * [Installing cask](#installing-cask)
      * [Setting up a Cask project file for your Emacs configuration](#setting-up-a-cask-project-file-for-your-emacs-configuration)
   * [Setting up Emacs](#setting-up-emacs)
      * [Installing irony-server](#installing-irony-server)
         * [Alternatively (less recommended), use company-rtags for code completion](#alternatively-less-recommended-use-company-rtags-for-code-completion)
      * [Trying it all out](#trying-it-all-out)
   * [TODO:s](#todos)
      * [Launching the RTags daemon (rdm) prior to Emacs - tmux example](#launching-the-rtags-daemon-rdm-prior-to-emacs---tmux-example)
      * [Look into cquery with lsp-mode and company-lsp](#look-into-cquery-with-lsp-mode-and-company-lsp)
   * [Contributing](#contributing)
   * [Acknowledgements](#acknowledgements)

# How to setup dfrib's basic Emacs environment

_(Recently tested for Emacs 25.3.2, at Ubuntu Xenial (16.04))_

## Background

This document describes how to setup my Emacs environment, which is mainly targeted for C++ development in CMake projects under Git version control.

It is intended to be a somewhat exhaustive guide aimed towards Emacs(/Linux) beginners, hopefully easing the task of setting up a basic Emacs C++/IDE-ish environment. I've experienced that this start-up phase can prove to be a barrier for actually dwelling into the wonders of Emacs, causing Emacs novice users to refrain from using Emacs beyond the scope of an unfamilar "editor".

## Overview

The core packages of my setup are:

- [`cmake-ide`](https://github.com/atilaneves/cmake-ide) with [`rtags`](https://github.com/Andersbakken/rtags) for IDE-like features on Emacs for CMake projects.
  - Where `rtags` fall back on [`clang`](https://clang.llvm.org/) as C++ parser.
  - Using [`flycheck`](https://github.com/flycheck/flycheck) for on-the-fly syntax checking.
  - Combined with [`company-mode`](http://company-mode.github.io/) and [`irony-mode`](https://github.com/Sarcasm/irony-mode) (and clang parsing) for code completion.
- [`magit`](https://magit.vc/) for any kind of Git interaction. `magit` is such an awesome Git client that I even sincerely recommend my non-Emacs-colleagues to turn to Emacs/`magit` _solely_ for using Git (naturally sneakily allowing to possibly tempt them to get into all other, never-ending additional upsides of using Emacs).
- [`ivy`](https://github.com/abo-abo/swiper) for minibuffer code completion.

Some other convenience packages worth mentioning (as they require Emacs-external dependencies) are:

- [`smart-mode-line`](https://github.com/Malabarba/smart-mode-line) with a powerline theme for a nice Emacs mode-line.
  - The `smart-mode-line-powerline-theme` requires you to install [Powerline fonts](https://github.com/powerline/fonts).
- [`plantuml-mode`](https://github.com/skuro/plantuml-mode) major mode for editing and swiftly pre-viewing PlantUML diagrams.
  - Naturally requires the `plantuml.jar`.

Finally, I use [`cask`](http://cask.readthedocs.io/en/latest/index.html) to manage package dependencies for my Emacs configuration, which will also hopefully make it easier to successfully follow this guide through, from start to finish.

# Installing pre-requisites
(Naturally `git`)

## Installing pre-requisites for the core packages

### CMake-IDE/RTags

Before we start, resync the package index files for APT:

```bash
$ sudo apt-get update
```

#### CMake

Make sure you have CMake installed:

```bash
$ cmake --version
```

If you have none installed (or if it's for some reason hideously old, < CMake 2.8), get it e.g. directly via Ubuntu/APT; at the time of writing this should install CMake 3.5.1, which suffices for RTags (even if it's somewhat old as compared to the latest release 3.10):

```bash
# CMake 3.5
$ sudo apt-get install cmake

# ... or install a more recent version "manually"
```

#### Clang/LLVM

Next up, we install clang and llvm. For Ubuntu Xenial, at the time of writing, `clang-4.0`/`llvm-4.0` are appropriate candidates (limiting ourselves to a stable branch; if you want e.g. 5.0 knock yourself out!):

```bash
$ sudo apt-get install clang-4.0 llvm-4.0 libclang-4.0-dev clang-format-4.0
```

You might also want to update to use `clang-4.0` to provide for `/usr/bin/clang` (which may be pointing to and older clang or missing entirely):

```bash
$ sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-4.0 100 \
--slave /usr/bin/clang++ clang++ /usr/bin/clang++-4.0 \
--slave /usr/bin/clang-check clang-check /usr/bin/clang-check-4.0 \
--slave /usr/bin/clang-query clang-query /usr/bin/clang-query-4.0 \
--slave /usr/bin/clang-rename clang-rename /usr/bin/clang-rename-4.0 \
--slave /usr/bin/clang-format clang-format /usr/bin/clang-format-4.0
```

Otherwise Emacs might prompt you that `clang` (or e.g. `clang-format`) cannot be found.

#### RTags/rdm (RTags daemon)

Clone the RTags project; I usually clone open source repos into my `~/opensource` folder:

```bash
$ cd ~/opensource
$ git clone --recursive https://github.com/Andersbakken/rtags.git
```

Build RTags:

```bash
# in ~/opensource
$ cd rtags
$ mkdir build
$ cd build
$ cmake ..
$ make
$ sudo make install
```

### Ivy

`ivy` contains a lot of goodies, but to point out some specifics I use `ivy` primarily for `swiper` in-buffer search and for the `counsel` (`ivy`-enhanced) Emacs commands. For the latter, most frequently `counsel-git` (find tracked file in current repo), `counsel-git-grep` and `counsel-ag`. The latter make use of [`ag` - The Silver Searcher](https://github.com/ggreer/the_silver_searcher), and is useful when wanting to search through only parts of a repository, limited to a folder and all tracked file therein (recursively for all sub-folders).

To allow using `counsel-ag`, install `ag`:

```bash
$ sudo apt-get install silversearcher-ag
```

## Installing pre-requisites for the convenience packages

### Smart-mode-line

For the `smart-mode-line-powerline-theme`, install [Powerline fonts](https://github.com/powerline/fonts):

```bash
# I generally put all open source repos under ~/opensource
$ cd ~/opensource

# clone
$ git clone https://github.com/powerline/fonts.git --depth=1

# install
$ cd fonts
$ ./install.sh
```

### PlantUML-mode

To make use of PlantUML-mode for UML diagram generation within Emacs, naturally we need to download the latest [`plantuml.jar`](http://plantuml.com/download). I've placed my copy in `~/opensource/plantuml/`.


# Installing Emacs 25

In case you're not already running an Emacs 25 version:

```bash
$ emacs --version # 25?
```

Then install it. To install a stable Emacs 25, use e.g. [Kevin Kelley's PPA](https://launchpad.net/~kelleyk/+archive/ubuntu/emacs):

```bash
# add PPA
$ sudo add-apt-repository ppa:kelleyk/emacs

# update APT and install (stable) emacs25
$ sudo apt-get update
$ sudo apt-get install emacs25
```

Ascertain, after installation, that you're not using an older version:

```bash
$ emacs --version # 25.X.Y?
```

I usually also make sure to remove any older versions; packages `emacsXY`/`emacsXY-...` which is not `emacs25`. To identify such packages, study the output of:

```bash
$ dpkg --get-selections | grep emacs
```

Or just tab-complete `sudo apt-get remove ...`.

To remove said packages use `apt-get remove --purge` (or just `apt-get purge`):

```bash
$ sudo apt-get remove --purge emacsXY
$ sudo apt-get remove --purge emacsXY-...
# et. cetera.
```

# Installing and setting up Cask

## Installing cask

To install Cask, run the following command:

```bash
$ curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
```

This should install Cask in `~/.cask/`. Make sure to follow the on-success prompt to add the `cask` binary to your path:

```bash
# e.g. in your .bashrc, or whatever shell you're using
export PATH="/home/dfri/.cask/bin:$PATH"
```

## Setting up a Cask project file for your Emacs configuration

The `emacs_setup` repo in which this `README.md` is a member also contains an `/.emacs.d/` folder. Copy the `/.emacs.d/Cask` file from this repo into your local `~/.emacs.d/` folder. If the `~/.emacs.d/` folder is missing, create it or simply start/close `emacs` once to let it be created automatically.

Moreover, create a (temporary) `init.el` file in your local `~/.emacs.d/` folder with the following content:

```bash
$ cd ~/.emacs.d/
$ touch init.el
```
```lisp
;; Add this into the init.el file (which is otherwise empty)
(package-initialize)
(require 'cask "~/.cask/cask.el")
(cask-initialize)

```

Your local `~/.emacs.d/` folder should now contain a `Cask` and an `init.el` file. Use `cask` to install all package dependencies contained in the `Cask` file:

```bash
$ cd ~/.emacs.d/
$ cask install
```

# Setting up Emacs

Replace the dummy `init.el` file from the step above with the `/.emacs.d/init.el` file of this repo. You might need to modify the `cmake-ide-build-dir` and `rtags-path` paths in the `init.el` file; they are both set to `~/opensource/rtags/build` by default.

## Installing irony-server

Upon first Emacs launch, install the `irony-server`, which provides the `libclang` interface to `irony-mode` (used for `company-irony` / code completion):

```bash
# In Emacs
M-x irony-install-server
# yields a cmake install command -> accept [RET]
```

A successful installation prompts you with _"`irony-server` installed successfully!"_.

### Alternatively (less recommended), use company-rtags for code completion

`rtags` (currently used for navigation and syntax checking) can be used as an alternative to `irony` for code completion, via its `company` backend `company-rtags`. In this case, you needn't install the `irony-server` above, but can fall back on the `rdm` deamon for a `libclang` interface. This will load `company-rtags` rather than `company-irony` as `company` backend; you will see such a setup commented out in the `Cask` file as well as in `init.el` file. Remember to re-install the Cask dependencies if you update the `Cask` file, as well as disabling `irony` as the code completion engine.

I would recommend using `irony` for completion, though, as I've had had better experience with it. I get the feeling that `rtags` is somewhat slower, but more stable (e.g. if running `emacs` and `irony-server` for a long time).

## Trying it all out

A good place to start trying out our Emacs/CMake-IDE/RTags setup is in the `rtags` repo that we already cloned above as part of installing RTags, as it covers a C++ CMake project (visit e.g. `rtags/src/rdm.cpp`).

Prior to launching `rdm` and `emacs` for this venture, make sure there is a `compile_commands.json` file present in the root for the project (`rtags/`). You might possibly need to copy the `compile_commands.json` file from `rtags/build/` to `rtags/`. If you can't find it in `build`, one can be generated directly into repo root using `cmake`:

```bash
$ cd ~/opensource/rtags/
$ cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .

# start rdm deamon (I've hade better experience using the --no-filemanager flag)
$ rdm --no-filemanager &

# start Emacs
$ emacs
```

If the `rdm` command is not found, you might possible need to add `~/opensrc/rtags/build/bin` to your `$PATH` variable; alternatively simply run `~/opensrc/rtags/build/bin/rdm --no-filemanager &` above to get the tryout going.

The `rdm` deamon can also be started from within Emacs, using e.g. the `(rtags-start-process-unless-running)` function, but I've had better experience in launching `rdm` prior to (and external from) `emacs`, e.g. using `tmux` (see next section). The `(rtags-start-process-unless-running)` command is present in the `init.el` file of this repo, but has been commented out.

That should be it. Good luck!

# TODO:s

## Launching the RTags daemon (rdm) prior to Emacs - tmux example

You can use e.g. [`tmux`](https://github.com/tmux/tmux/wiki) to automatically start `rdm` (with `--no-filemanager`) prior to launching Emacs, e.g. keeping the rdm output in a minor pane to get a feeling of `rdm`'s "state" in case Emacs feezes up.

E.g., create a `dev-tmux.sh` file that can be used to start up your dev environment:

```bash
#!/bin/sh
tmux new-session -s 'emacs' -d 'rdm -v --no-filemanager'
tmux split-window -h
tmux resize-pane -L 40
tmux select-pane -L
tmux split-window -v
tmux resize-pane -U 10
tmux select-pane -R
tmux new-window -d 'emacs25 --visit "/path/to/root/of/your/project/"'
tmux -2 attach-session -d
```

Yielding, roughly:

```
---------------------------------
|           |                   |
|  rdm log  |                   |
|           |                   |
|-----------|   main terminal   |  +  Emacs @ /path/to/root/of/your/project/
|           |                   |
| secondary |                   |
| terminal  |                   |
|           |                   |
---------------------------------
```

## Look into cquery with lsp-mode and company-lsp

_**TODO:**_

Look into testing [`cquery`](https://github.com/jacobdufault/cquery) with [`lsp-mode`](https://github.com/emacs-lsp/lsp-mode) and [`company-lsp`](https://github.com/tigersoldier/company-lsp) as an alternative to `rtags` and `company-irony`/`company-rtags`. `cquery` is still in its early phases, especially w.r.t. using it with Emacs, but it looks very promising. One can follow the work of `cquery` (and keep one's eye out for Emacs related successes) in [the Gitter lobby of the `cquery-project`](https://gitter.im/cquery-project/Lobby).

# Contributing

I'm neither an Emacs hacker nor proficient in elisp, and will thus happily receive pull requests to improve this guide, e.g. re-formatting the `init.el` file to "best Emacs Lisp practices", or removing possible redundant information or steps above. I'd like to avoid, though, expanding with additional packages and modes, as the Emacs setup covered herein is my own turn-to guide for setting up my personally flavoured "minimal" Emacs setup.

# Acknowledgements

To Ian K for once upon a time enthusiastically introducing me to Emacs, something I always try to pass on to my non-Emacs using friends and colleagues.
