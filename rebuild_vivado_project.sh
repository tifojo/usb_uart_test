#!/bin/bash

set -e

if [ -d vivado_project ]; then
    mv vivado_project vivado_project_old
fi
mkdir vivado_project
cd vivado_project
vivado -source ../generate_vivado_project.tcl