#!/usr/bin/env bash

#in case of error
read -p "Delete prevoius builds? [yn]" answer
if [[ $answer = y ]]; then
  rm -rf build*
fi

#re-download all again
read -p "Download all modules again? [yn]" answer
if [[ $answer = y ]]; then
 rm -rf dune*
 
 #core modules
 git clone --branch releases/2.6 https://gitlab.dune-project.org/core/dune-common.git
 git clone --branch releases/2.6 https://gitlab.dune-project.org/core/dune-geometry.git
 git clone --branch releases/2.6 https://gitlab.dune-project.org/core/dune-grid.git
 git clone --branch releases/2.6 https://gitlab.dune-project.org/core/dune-localfunctions.git
 git clone --branch releases/2.6 https://gitlab.dune-project.org/core/dune-istl.git

 #typetree needed
 git clone --branch releases/2.6 https://gitlab.dune-project.org/staging/dune-typetree.git
 git clone --branch releases/2.6 https://gitlab.dune-project.org/staging/dune-uggrid.git

 #extension functions module
 git clone https://gitlab.dune-project.org/staging/dune-functions.git
 cd dune-functions
 git checkout bd847eb9f6617b116f5d6cb4930e5417d7b6e9a7
 git checkout -b c-interface
 cd ..

 #pdelab and  required
 git clone --branch releases/2.6 https://gitlab.dune-project.org/pdelab/dune-pdelab.git

 #duneuro 
 git clone --branch feature/c-interface-compatibility https://gitlab.dune-project.org/duneuro/duneuro.git 
 git clone --branch feature/c-interface https://gitlab.dune-project.org/duneuro/duneuro-matlab.git

 # Fortran patch
 printf "\n\n#####################################################\n\n               Performing fortran patch!!\n\n#####################################################\n"
 sed -i 's/workaround_9220(Fortran Fortran_Works)/if(ENABLE_Fortran)\n    workaround_9220(Fortran Fortran_Works)\n  endif()/g' dune-common/cmake/modules/DuneMacros.cmake 
fi


 #make
read -p "Build? [yn]" answer
if [[ $answer = y ]]; then
  rm -rf */build_release
  read -p "Save build output in building_output.txt? [yn]" answer
  if [[ $answer = y ]]; then
    dune-common/bin/dunecontrol --opts=config_release_windwos.opts --builddir=`pwd`/build_release all &> building_output.txt
    tail -f building_output.txt
  else
    dune-common/bin/dunecontrol --opts=config_release_windows.opts --builddir=`pwd`/build_release all
  fi
fi

#build library file
read -p "Build .lib library? [yn]" answer
if [[ $answer = y ]]; then
  cd build_release/duneuro-matlab/src
  /usr/bin/x86_64-w64-mingw32-dlltool --verbose -m i386:x86-64 -z libduneuro.def --export-all-symbols libduneuromat.dll
  /usr/bin/x86_64-w64-mingw32-dlltool --verbose -d libduneuro.def -D libduneuromat.dll -l duneuromat.lib
  cp libduneuromat.dll ../..
  cp libduneuro.def ../..
  cp duneuromat.lib ../..
  cd ../../..
fi

#make the final executable applications in duneuro-matlab/bst
read -p "Generate final exe applications? [yn]" answer
if [[ $answer = y ]]; then
  dune-common/bin/dunecontrol --only=duneuro-matlab --opts=config_release_windows.opts --builddir=`pwd`/build-release all
fi

  dune-common/bin/dunecontrol --module=duneuro-matlab --opts=config_release_windows.opts --builddir=`pwd`/build-release all




