import PISM
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument("FILE", nargs=1, help="Bootstrap file", default=None)
parser.add_argument("--routing_file", dest="routing_file", help="routing file", default=None)

options = parser.parse_args()
input_file = options.FILE[0]
routing_file = options.routing_file

context = PISM.Context()
ctx = context.ctx
config = context.config
config.set_string("frontal_melt.routing.file", routing_file)

registration = PISM.CELL_CENTER


grid = PISM.IceGrid.FromFile(ctx, input_file, ("bed", "thickness"), registration)
geometry = PISM.Geometry(grid)
geometry.ice_thickness.regrid(input_file, critical=True)
geometry.bed_elevation.regrid(input_file, critical=True)
min_thickness = config.get_double("geometry.ice_free_thickness_standard")
geometry.ensure_consistency(min_thickness)

theta = 1.0
salinity = 0.0

inputs = PISM.FrontalMeltInputs()
cell_area = grid.dx() * grid.dy()
water_density = config.get_double("constants.fresh_water.density")

Qsg = PISM.IceModelVec2S(grid, "subglacial_water_mass_change_at_grounding_line", PISM.WITHOUT_GHOSTS)
Qsg.set_attrs("climate", "subglacial discharge at grounding line", "kg", "kg")
# Qsg.set(self.subglacial_discharge * cell_area * water_density * self.dt)

model = PISM.FrontalMeltDischargeRouting(grid)
model.init(geometry)
# model.update(inputs, 0, 0.1)
