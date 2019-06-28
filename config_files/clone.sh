#!/usr/bin/env bash
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
