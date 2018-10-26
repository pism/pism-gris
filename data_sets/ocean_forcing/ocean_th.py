import PISM
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("FILE", nargs=1, help="Bootstrap file", default=None)
parser.add_argument(
    "--ocean_file",
    dest="ocean_file",
    help="File containing theta_ocean and salinity_ocean",
    default=None,
)

options = parser.parse_args()
input_file = options.FILE[0]
ocean_file = options.ocean_file

context = PISM.Context()
ctx = context.ctx
config = context.config
registration = PISM.CELL_CENTER


grid = PISM.IceGrid.FromFile(ctx, input_file, ("bed", "thickness"), registration)
geometry = PISM.Geometry(grid)
geometry.ice_thickness.regrid(input_file, critical=True)
geometry.bed_elevation.regrid(input_file, critical=True)
min_thickness = config.get_double("geometry.ice_free_thickness_standard")
geometry.ensure_consistency(min_thickness)


config.set_string("ocean.th.file", ocean_file)
PISM.util.prepare_output(ocean_file)


salinity = 35.0
potential_temperature = 270.0

Th = PISM.IceModelVec2S(grid, "theta_ocean", PISM.WITHOUT_GHOSTS)
Th.set_attrs("climate", "potential temperature", "Kelvin", "")
Th.set(potential_temperature)
Th.write(ocean_file)

S = PISM.IceModelVec2S(grid, "salinity_ocean", PISM.WITHOUT_GHOSTS)
S.set_attrs("climate", "ocean salinity", "g/kg", "")
S.set(salinity)
S.write(ocean_file)


model = PISM.OceanGivenTH(grid)
model.init(geometry)
model.update(geometry, 0, 1)


out_filename = "given_th_output.nc"
PISM.util.prepare_output(out_filename)

model.shelf_base_mass_flux().write(out_filename)
model.shelf_base_temperature().write(out_filename)
