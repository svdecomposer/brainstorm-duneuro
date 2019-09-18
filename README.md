# brainstorm-duneuro
DuNeuro integration into Brainstorm Toolbox for advanced FEM forward modelling.

## Description of the files
Initially you will find two main folders: 

#### /apps 
All the different applications are stored here. For instance, continuous Galerkin, Tet-based FEM solutions for EEG and for MEG are stored here.

#### /config_files
Setup scripts and different configuration files for each version.

#### /data
This folder stores subject's data, meshes, models and other information.

## initial setup
This repo is concieved to work in a linux or mac environment. So far it works fine in an ubuntu 10.04 lts. Windows executables will be generated through cross-compilation with mingw, executed in a linux environment.

1. update needed system libraries 
   in a new 18.04 lts ubuntu we need the following packages:
   ```
   sudo apt-get install mingw-w64 g++-mingw-w64 libc6-dev-i386
   ```
   
2. clone this repository

```git
git clone --branch testing https://github.com/svdecomposer/brainstorm-duneuro.git
```

## Compilation

### windows version

1. execute setup_windows.h (for release build).
   The main difference with the linux version is that the compiler is changed.
   The fortran patch.

Set the configuration script as executable:
```bash
sudo chmod +x config_files/setup_windows.sh
```

Execute setup_windows.sh

```bash
./config_files/setup_windows.sh
```
### linux version
1. execute setup_linux.h (for release build).
```
./setup_linux.h
```

  comments on options...
  verify the files config_release_linux.opts and config_debug_linux.opts exist.
  remember it is always desirable to have clean build folders.
  if problems use a 'building_outupt.txt' file and share.
2. create link to bst folder inside duneuro
3. build new exercise.
   eeg
   meg
   seeg

### mac version
1. execute setup_mac.h (for release build).




>>>>>>> unfinished <<<<<<<<<


