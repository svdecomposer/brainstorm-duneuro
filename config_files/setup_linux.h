#!/usr/bin/env bash

#in case of error
read -p "Delete prevoius builds? [yn]" answer
if [[ $answer = y ]]; then
  rm -rf build_*
fi

#re-download all again
read -p "Download all modules again? [yn]" answer
if [[ $answer = y ]]; then
 rm -rf duneuro
 mkdir duneuro
 cd duneuro

 for i in common geometry localfunctions grid istl; do
	git clone --branch releases/2.5 https://gitlab.dune-project.org/core/dune-$i.git;
 done;
 for i in functions typetree uggrid; do
	git clone --branch releases/2.5 https://gitlab.dune-project.org/staging/dune-$i.git;
 done;
 for i in pdelab; do
	git clone --branch releases/2.5 https://gitlab.dune-project.org/pdelab/dune-$i.git;
 done;
 for i in duneuro; do
	git clone --branch releases/2.5 https://gitlab.dune-project.org/duneuro/$i.git;
 done;
 for i in duneuro-matlab duneuro-py; do
 	git clone --branch releases/2.5 --recursive https://gitlab.dune-project.org/duneuro/$i.git;
 done;

 cd ..
fi

#make
read -p "Build? [yn]" answer
if [[ $answer = y ]]; then
  read -p "Save build output in building_output.txt? [yn]" answer
  if [[ $answer = y ]]; then
    duneuro/dune-common/bin/dunecontrol --opts=config_files/config_release_linux.opts --builddir=`pwd`/build_release_linux_$(date +%m_%d_%y_%k_%M_%S) all &> building_output_$(date +%m_%d_%y_%k_%M_%S).txt &
    sleep .5
    tail -f building_output_$(date +%m_%d_%y_%k_%M_%S).txt
  else
    duneuro/dune-common/bin/dunecontrol --opts=config_files/config_release_linux.opts --builddir=`pwd`/build_release_linux_$(date +%m_%d_%y_%k_%M_%S) all
  fi
fi


