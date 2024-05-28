Run HEMCO at 4 x 5 and 0.5 x 0.625 for April 2018.
1. `bash bash/run-hemco.sh`

Generate emissions files for the different base and perturbation scenarios.
2. `sbatch --mem 4000 --wrap "source ~/.bashrc; micromamba activate ldf_env; python python/make-emissions.py"`

Generate restart file with 1 ppb background.
3. `sbatch --mem 4000 --wrap "source ~/.bashrc; micromamba activate ldf_env; python python/make-restart.py"`

Run all of the global GEOS-Chem simulations.
4. `bash bash/run-global-gc.sh`

Use output of global GEOS-Chem simulation to make 1 ppb boundary conditions.
5. `sbatch --mem 4000 --wrap "source ~/.bashrc; micromamba activate ldf_env; python python/make-bcs.py"`

Run all of the nested GEOS-Chem simulations.
6. `bash bash/run-nested-gc.sh`