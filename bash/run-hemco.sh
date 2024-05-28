#!/bin/bash

source /n/home06/nbalasus/envs/gcclassic.rocky+gnu10.minimal.env
dir="${SCRATCH}/jacob_lab/${USER}/jacobian"
emis_dir="${dir}/emis"
mkdir -p "${emis_dir}"
cd "${emis_dir}"

for domain in global nested; do

    # Compile GCClassic 14.3.1 for CH4/MERRA2/47 L
    # 4 x 5 for global and 0.5 x 0.625 NA for nested
    # This is just to fill in HEMCO_Config.rc to run standalone
    git clone https://github.com/geoschem/GCClassic.git
    cd GCClassic
    git checkout 14.3.1
    git submodule update --init --recursive
    cd run
    gc_dir="${domain}_gc"
    if [[ $domain = global ]]; then
        c="3\n1\n1\n2\n${emis_dir}\n${gc_dir}\nn\n"
    elif [[ $domain = nested ]]; then
        c="3\n1\n3\n1\n2\n${emis_dir}\n${gc_dir}\nn\n"
    fi
    printf ${c} | ./createRunDir.sh
    cd "${emis_dir}/${gc_dir}/build"
    cmake ../CodeDir -DRUNDIR=..
    make -j
    make install

    # Compile HEMCO for GEOS-FP
    # 2 x 2.5 for global and 0.25 x 0.3125 for nested
    cd "${emis_dir}/${gc_dir}/CodeDir/src/HEMCO/run"
    HEMCO_Config="${emis_dir}/${gc_dir}/HEMCO_Config.rc"
    hemco_dir="${domain}_hemco"
    if [[ $domain = global ]]; then
        c="1\n1\n${HEMCO_Config}\n${emis_dir}\n${hemco_dir}\nn\n"
    elif [[ $domain = nested ]]; then
        c="1\n3\n${HEMCO_Config}\n${emis_dir}\n${hemco_dir}\nn\n"
    fi
    printf ${c} | ./createRunDir.sh
    cd "${emis_dir}/${hemco_dir}/build"
    cmake ../CodeDir -DRUNDIR=..
    make -j
    make install

    # Setup to run for April 2018
    # Scale soil absorption by 0.0
    cd "${emis_dir}/${hemco_dir}"
    sed -i -e "s|2019-07-01|2018-04-01|g" \
        -e "s|2019-08-01|2018-05-01|g" HEMCO_sa_Time.rc
    sed -i -e "s|huce_intel|sapphire|g" \
        -e "s|8|32|g" \
        -e "s|15000|128000|g" runHEMCO.sh
    sed -i -e "s|1 NEGATIVE       -1.0|1 NEGATIVE       0.0|g" HEMCO_Config.rc
    sbatch runHEMCO.sh

done