import os
import subprocess
import xarray as xr

if __name__ == "__main__":
    
    # Directory to save modified restarts
    dir = "/n/home06/nbalasus/holyscratch01/jacobian/restarts/"
    os.makedirs(dir, exist_ok=True)

    # Download Todd's Restart file
    subprocess.run(["wget", "-q", "https://github.com/geoschem/integrated_methane_inversion/raw/dev/src/write_BCs/GEOSChem.Restart.20180401_0000z.nc4", "-P", dir])

    # Modify to be 1 ppb everywhere
    with xr.open_dataset(dir+"GEOSChem.Restart.20180401_0000z.nc4") as ds:
        modified = ds.copy(deep=True)

    modified["SpeciesRst_CH4"] *= 0.0
    modified["SpeciesRst_CH4"] += 1e-9
    modified.to_netcdf(dir+"GEOSChem.Restart.1ppb.20180401_0000z.nc4")