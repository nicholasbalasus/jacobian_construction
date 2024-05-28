import os
import xarray as xr

if __name__ == "__main__":

    # Read HEMCO Output
    dir = "/n/home06/nbalasus/holyscratch01/jacobian/emis"
    with xr.open_dataset(f"{dir}/nested_hemco/OutputDir/HEMCO_sa_diagnostics.201804010000.nc") as nest:
        nest_orig = nest.copy(deep=True)
    with xr.open_dataset(f"{dir}/global_hemco/OutputDir/HEMCO_sa_diagnostics.201804010000.nc") as glob:
        glob_orig = glob.copy(deep=True)

    # Directory to save modified emisisons files
    dir = "/n/home06/nbalasus/holyscratch01/jacobian/emis/modified_emis/"
    os.makedirs(dir, exist_ok=True)

    # Perturbation percents
    percents = [10**i for i in range(-3,9)]

    # Scenarios (1) and (2)

    # Global grid
    base = glob_orig.copy(deep=True)
    ilat = base.indexes["lat"].get_loc(42)
    ilon = base.indexes["lon"].get_loc(-100)
    base["EmisCH4_Total"] *= 0.0
    base["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10
    base.to_netcdf(dir+"global-zeroed-base.nc")
    for idx,percent in enumerate(percents):
        pert = base.copy(deep=True)
        pert["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10 + (1e-10*percent/100)
        pert.to_netcdf(dir+f"global-zeroed-pert-{idx}.nc")

    # Nested grid
    base = nest_orig.copy(deep=True)
    ilat = base.indexes["lat"].get_loc(42)
    ilon = base.indexes["lon"].get_loc(-100)
    base["EmisCH4_Total"] *= 0.0
    base["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10
    base.to_netcdf(dir+"nested-zeroed-base.nc")
    for idx,percent in enumerate(percents):
        pert = base.copy(deep=True)
        pert["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10 + (1e-10*percent/100)
        pert.to_netcdf(dir+f"nested-zeroed-pert-{idx}.nc")

    # Scenario (3) and (4)

    # Global grid
    base = glob_orig.copy(deep=True)
    ilat = base.indexes["lat"].get_loc(42)
    ilon = base.indexes["lon"].get_loc(-100)
    base["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10
    base.to_netcdf(dir+"global-normal-base.nc")
    for idx,percent in enumerate(percents):
        pert = base.copy(deep=True)
        pert["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10 + (1e-10*percent/100)
        pert.to_netcdf(dir+f"global-normal-pert-{idx}.nc")

    # Nested grid
    base = nest_orig.copy(deep=True)
    ilat = base.indexes["lat"].get_loc(42)
    ilon = base.indexes["lon"].get_loc(-100)
    base["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10
    base.to_netcdf(dir+"nested-normal-base.nc")
    for idx,percent in enumerate(percents):
        pert = base.copy(deep=True)
        pert["EmisCH4_Total"].values[0,ilat,ilon] = 1e-10 + (1e-10*percent/100)
        pert.to_netcdf(dir+f"nested-normal-pert-{idx}.nc")