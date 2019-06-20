#!/usr/bin/env bash

#in case of error
read -p "Delete prevoius builds? [yn]" answer
if [[ $answer = y ]]; then
  rm -rf build_*
fi

#re-download all again
read -p "Download all modules again? [yn]" answer
if [[ $answer = y ]]; then
 rm -rf dune*

 ver_num="2.6"

 #core modules
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/core/dune-common.git
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/core/dune-geometry.git
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/core/dune-grid.git
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/core/dune-localfunctions.git
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/core/dune-istl.git

 #typetree needed
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/staging/dune-typetree.git
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/staging/dune-uggrid.git

 #extension functions module
 git clone https://gitlab.dune-project.org/staging/dune-functions.git
 cd dune-functions
 git checkout bd847eb9f6617b116f5d6cb4930e5417d7b6e9a7
 git checkout -b c-interface
 cd ..

 #pdelab and  required
 git clone --branch releases/$ver_num https://gitlab.dune-project.org/pdelab/dune-pdelab.git

 #duneuro 
 git clone --branch feature/c-interface-compatibility https://gitlab.dune-project.org/duneuro/duneuro.git 
 git clone --branch feature/c-interface https://gitlab.dune-project.org/duneuro/duneuro-matlab.git

fi


#make
read -p "Build? [yn]" answer
if [[ $answer = y ]]; then
  rm -rf build_*
  read -p "Save build output in building_output.txt? [yn]" answer
  if [[ $answer = y ]]; then
    dune-common/bin/dunecontrol --opts=config_release_linux.opts --builddir=`pwd`/build-release_linux all & > building_output.txt
    tail -f building_output.txt
  else
    dune-common/bin/dunecontrol --opts=config_release_linux.opts --builddir=`pwd`/build-release_linux all
  fi
fi


