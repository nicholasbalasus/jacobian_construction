import os
import glob
import subprocess
import xarray as xr

if __name__ == "__main__":

    # Directory to save boundary conditions
    dir1 = "/n/home06/nbalasus/holyscratch01/jacobian/bcs/normal/"
    dir2 = "/n/home06/nbalasus/holyscratch01/jacobian/bcs/one_ppb/"
    os.makedirs(dir1, exist_ok=True)
    os.makedirs(dir2, exist_ok=True)

    # Copy over BCs from global run and optionally modify to 1 ppb
    files = sorted(glob.glob("/n/home06/nbalasus/holyscratch01/jacobian/global/scenario-4/base/gc/OutputDir/*Boundary*"))
    for file in files:
        subprocess.run(["cp", file, dir1])

        with xr.open_dataset(file) as ds:
            modified = ds.copy(deep=True)

        modified["SpeciesBC_CH4"] *= 0.0
        modified["SpeciesBC_CH4"] += 1e-9
        modified.to_netcdf(dir2+os.path.basename(file))