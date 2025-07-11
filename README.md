# Bibber: bibtex tool to sort/filter bibtex and convert to different outputs

The `bibber` tool is a bibtex tool to sort/filter bibtex and convert to different
outputs.

The `bibber` tool is written in the
[Clean programming language](http://clean.cs.ru.nl/). This repository contains a
Clean project that uses the Clean distribution installed with the `nitrile` tool. As
alternative it also contains scripts to easily let you build the project with the
'classic' Clean distribution using the `cpm` or `clm` tool.

## Install

This project can be used using a devcontainer which automatically setups a
development environment with nitrile and Clean for you in a docker container from
which you can directly start developing. Look
[here](https://github.com/harcokuppens/clean-nitrile-helloworld/blob/main/DevContainer.md)
for more details how to use the devcontainer in vscode.

However you offcourse can use this project on your local machine by install nitrile
and clean yourself:

- to install nitrile see https://clean-lang.org/about.html#install .
- to use nitrile to install Clean and Clean libraries, and build clean projects see
  https://clean-and-itasks.gitlab.io/nitrile/intro/getting-started/

## Build bibber

To build bibber with nitrile, first install the clean distribution in your project
folder in the `./nitrile-packages` folder using the `nitrile` command. With `nitrile`
you can install the clean distribution, update and fetch the required nitrile
packages in the `./nitrile-packages` folder as specified in `nitrile.yml` using the
commands:

```sh
nitrile update
nitrile fetch
```

After installing nitrile and Clean you can read in environment to also use extra
nitrile helper applications in `bin-nitrile`:

```sh
source env.bash
```

Then you can (re)build `bibber` with the command:

```sh
nitrile build
```

which builds the binary in `bin/bibber`.

We can cleanup the project from all build artifacts, so that only its original
sources remain, by running the cleanup script:

```sh
./cleanup.bash
```

Next to cleaning up the project, above script can also cleanup the clean distribution
installed in your project:

```sh
./cleanup.bash --all
```

One can always reinstall the clean distribution in your project folder in the
container by rerunning: `nitrile update; nitrile fetch`

## Usage

Usage of `bibber` command is shown when running it without arguments:

```
$ bibber
bibber - bibtex tool to sort/filter bibtex and convert to different outputs

usage: bibber  inputfile outputfile [--filter "field:value,.."]  [--sort "[+-]field,.."]
                [--output format]  [--latex2html]  [--limit-fields]

where:
       inputfile:  input filename, if this is "-" input is read from stdin
       outputfile:  output filename, if this is "-" input is read from stdin
       output: output format which can be origbib,ppbib,html,htmlsectioned
               where htmlsectioned is sectioned on first sort field.
               If no sortfield is given "-year" is used.
               Default output format is "origbib". The origbib format means
               outputting the bibtex entries with the original formatting as
               in the source file. The ppbib format however does output bibtex
               with pretty printing applied.
       latex2html: convert field values from latex to html
       limit-fields: limit output fields. Has no effect on output 'origbib'
                     which outputs the original bibtex only sorted and filtered.


```

## Extra: build of bibber using 'classic' Clean distribution from [https://clean.cs.ru.nl/](https://clean.cs.ru.nl/)

Instead of using `nitrile` distibution of Clean, we can also build bibber using
'classic' Clean distribution from [https://clean.cs.ru.nl/](https://clean.cs.ru.nl/).

We can do this by doing the following steps:

- install Clean from https://clean.cs.ru.nl/ using the bash script

  ```sh
  ./install-clean.bash
  source env.bash
  ```

- build project

  - with `cpm` project manager

    ```sh
    cpm bibber.prj
    ```

  - with `clm` using the bash script:

    ```sh
    ./build-clm.bash
    ```

Note, that the same `cleanup.bash` script can be used to also remove build files
build with `nitrile` or `cpm` or `clm` in this clean project. You can also use run
the command `./cleanup.bash --all` which next to cleaning up the project also does
cleanup the clean distribution installed in your project. One can always reinstall
the 'classic' Clean distribution in your project folder in the container by
rerunning: `./install-clean.bash`

Note, that the clean language server, named Eastwood, used in the devcontainer uses
the `Eastwood.clm` configuration file to specify all folder with clean source. If you
switch between the  nitrile  or the 'classic' Clean distribution you must also
adapt the libraries specified in the the `Eastwood.clm` configuration file  to
match the distribution. 

For the nitrile Clean distribution create a `Eastwood.clm` configuration  with 
the command:

```sh
nitrile-eastwood
```

For the 'classic' Clean distribution create a `Eastwood.clm` configuration  with 
the command:

```sh
cp resources/Eastwood.classic.yml Eastwood.yml
```

Note that this repository by default supplies the nitrile's `Eastwood.yml` file.
