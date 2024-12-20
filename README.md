# Bibber: bibtex tool to sort/filter bibtex and convert to different outputs

The `bibber` tool is a bibtex tool to sort/filter bibtex and convert to different
outputs.

The `bibber` tool is written in the
[Clean programming language](http://clean.cs.ru.nl/). This repository contains a
Clean project that uses a clean distribution installed with the `nitrile` tool.

## Install

This project can be used using a devcontainer which automatically setups a
development environment with nitrile and Clean for you in a docker container from
which you can directly start developing. Look
[here](https://https://github.com/harcokuppens/clean-nitrile-helloworld) for more
details how to use the devcontainer in vscode.

However you offcourse can use this project on your local machine by install nitrile
and clean yourself:

- to install nitrile see https://clean-lang.org/about.html#install .
- to use nitrile to install Clean and Clean libraries, and build clean projects see
  https://clean-and-itasks.gitlab.io/nitrile/intro/getting-started/

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
