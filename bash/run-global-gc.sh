#!/bin/bash

source /n/home06/nbalasus/envs/gcclassic.rocky+gnu10.minimal.env
dir="${SCRATCH}/jacob_lab/${USER}/jacobian"

for run in base pert-{0..11}; do
    for scenario in 1 2 3 4; do

        run_dir="${dir}/global/scenario-${scenario}/${run}"
        mkdir -p "${run_dir}"
        cd "${run_dir}"

        # Compile GCClassic 14.3.1 for CH4/MERRA2/4x5/47 L
        git clone https://github.com/geoschem/GCClassic.git
        cd GCClassic
        git checkout 14.3.1
        git submodule update --init --recursive
        cd run
        gc_dir="gc"
        c="3\n1\n1\n2\n${run_dir}\n${gc_dir}\nn\n"
        printf ${c} | ./createRunDir.sh
        cd "${run_dir}/${gc_dir}/build"
        cmake ../CodeDir -DRUNDIR=..
        make -j
        make install
        cd "${run_dir}/${gc_dir}"

        # Modify HEMCO_Config.rc
        # Read only summed emissions (depending on scenario)
        # Modify the group 1 scale factor to be * 0.0
        
        if [ "$scenario" -eq 1 ] || [ "$scenario" -eq 2 ]; then
            emis_type="zeroed"
        elif [ "$scenario" -eq 3 ] || [ "$scenario" -eq 4 ]; then
            emis_type="normal"
        fi
        sed -i -e "s|UseTotalPriorEmis      :       false|UseTotalPriorEmis      :       true|g" \
            -e "s|GFED                   : on|GFED                   : off|g" \
            -e "s|../../prior_run/OutputDir/HEMCO_sa_diagnostics.\$YYYY\$MM\$DD0000.nc|${dir}/emis/modified_emis/global-${emis_type}-${run}.nc|g" \
            -e "s|1 NEGATIVE       -1.0|1 NEGATIVE       0.0|g" HEMCO_Config.rc

        # Optionally scale losses to zero
        if [ "$scenario" -eq 1 ] || [ "$scenario" -eq 3 ]; then
            sed -i -e "s|CH4loss  1985/1-12/1/0 C xyz s-1 \* - 1 1|CH4loss  1985/1-12/1/0 C xyz s-1 \* 1 1 1|g" \
                -e "s|OH           1985/1-12/1/0 C xyz kg/m3 \* 2 1 1|OH           1985/1-12/1/0 C xyz kg/m3 \* 1/2 1 1|g" \
                -e "s|SpeciesConc_Cl    2010-2019/1-12/1/0 C xyz 1        \* - 1 1|SpeciesConc_Cl    2010-2019/1-12/1/0 C xyz 1        \* 1 1 1|g" HEMCO_Config.rc
        fi

        # Modify HISTORY.rc
        # Archive instantaneous, hourly CH4 and dry air
        # Archive boundary conditions
        sed -i -e "s|'CH4',|#'CH4',|g" \
            -e "s|'Metrics',|#'Metrics',|g" \
            -e "s|#'BoundaryConditions',|'BoundaryConditions',|g" \
            -e "s|00000100 000000|00000000 010000|g" \
            -e "s|time-averaged|instantaneous|g" \
            -e "s|'SpeciesConcMND_?ALL?|#'SpeciesConcMND_?ALL?|g" \
            -e "s|'Met_AD                        ',|'Met_AIRVOL                    ',|g" HISTORY.rc
        sed -i '269,344d' HISTORY.rc

        # Replace the Restart file
        rm Restarts/GEOSChem.Restart.20190101_0000z.nc4
        if [ "$scenario" -eq 1 ] || [ "$scenario" -eq 2 ]; then
            cp "${dir}/restarts/GEOSChem.Restart.1ppb.20180401_0000z.nc4" Restarts/GEOSChem.Restart.20180401_0000z.nc4
        elif [ "$scenario" -eq 3 ] || [ "$scenario" -eq 4 ]; then
            cp "${dir}/restarts/GEOSChem.Restart.20180401_0000z.nc4" Restarts/GEOSChem.Restart.20180401_0000z.nc4
        fi
        
        # Run for April 2018
        sed -i -e "s|20190101|20180401|g" \
            -e "s|20190201|20180501|g" geoschem_config.yml

        # Modify the run script then submit it
        cp runScriptSamples/operational_examples/harvard_cannon/geoschem.run .
        sed -i -e "s|-c 8|-c 32|g" \
            -e "s|0-12:00|0-24:00|g" geoschem.run
        sbatch geoschem.run

    done
done