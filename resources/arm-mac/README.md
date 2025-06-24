
# Install Clean for X64 MacOS on ARM MacOS

## Description 

On  a `ARM64` Mac using Rosetta emulation for `x64` you can install the Clean compiler for `x64` Macs,
and then compile Clean programs for `x64` which then also run on that Mac using Rosetta emulation for `x64`.
However you need to patch the 'classic' Clean installation for `x64` Macs to get the installation working
correctly on a `ARM64` Mac.

## Installation

Run the following commands in your bash shell:

```bash
bash install-clean-for-x64-mac-on-arm-mac.bash
source ~/.bashrc
```

Now Clean is installed in your home directory at  `~/clean3.1/`, 
and its `bin` path is added to your `$PATH` variable.

## What is done in the patch?

* give the the architecture option `-arch x86_64`  to gcc 
* TRICK: added extra option to the  `clm` command `-l -arch -l x86_64` which \
  causes the architecture option `-arch x86_64` to be given to the linker via `clm`



