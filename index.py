import meep           as mp
import meep.materials as mat
import numpy          as np
import math           as math

resolution = 200

# ABSORB
pmlW       = 0.05
pml_layers = [mp.PML(pmlW)]

# STUFF
Vac     = mp.Medium(epsilon = 1)
SiO2    = mp.Medium(epsilon = 1.5**2)
BTO     = mp.Medium(epsilon = 2.5**2)
STO     = mp.Medium(epsilon = 3.3**2)
TiN     = mp.Medium(epsilon = 3.1**2)
SiN     = mp.Medium(epsilon = 2.0**2)
Al2O3   = mp.Medium(epsilon = 1.75**2)
Au      = mat.Au
cSi     = mat.cSi

2.5/3.3 * 0.375 # 
2.5/3.3 * 0.125 # 
2.5/3.3 * 1.5   # 
0.05            # 

subH    = 0     # 0.10      # Si Substrate
buffH   = 0.500     # TiN buffer
baseH   = 0.500 # 0.0165    # STO Base Thickness
wvgH    = 0     # 0.0089    # STO Waveguide Thickness
wvgW    = 0.5   # 0.230     # STO Wvg Width
topH    = 0     # 0.165     # BTO/AuVAN Thickness
VAN_R   = 0.0025    # Nanopillar radius
VAN_sp  = 0.0175    # Nanopillar spacing
vaccH   = topH      # Vacuum on top

simW    = wvgW * 2
simH    = subH + buffH + baseH + topH + vaccH
simD    = wvgW * 2
cell    = mp.Vector3(simW, simH, simD) 

# ARRAY TOOLS
# DFS add all elements in nested array to a flattened array
def flatten(arr, flattened = []):
    if not isinstance(arr, list):  
        flattened.append(arr)
        return

    for subArr in arr:
        flatten(subArr, flattened)
    
    return flattened

def BlockRel(ref, mat, delX, delY, delZ, W, H, D):
    return mp.Block(
        center   = ref.center + mp.Vector3(delX, delY, delZ),
        size     = mp.Vector3(W, H, D),
        material = mat
    )

def FillVANs(ref, mat, radius, spacing):
    
    VANs   = []
    
    height = ref.size.y

    startX = ref.center.x - ref.size.x/2 + spacing/6
    startZ = ref.center.z - ref.size.z/2 + spacing/6
    stopX  = ref.center.x + ref.size.x/2
    stopZ  = ref.center.z + ref.size.z/2
    Y      = ref.center.y

    X = startX
    while X <= stopX:
        Z = startZ
        while Z <= stopZ:
            VANs.append(mp.Cylinder(
                radius      = radius,
                axis        = mp.Vector3(0, 1, 0),
                height      = height,
                center      = mp.Vector3(X, Y, Z),
                material    = mat
            ))
            Z += spacing
        X += spacing

    return VANs

substrate = mp.Block(material = cSi, center = mp.Vector3(0, -simH/2 + subH/2, 0), size = mp.Vector3(simW, subH, simD))
buffer    = BlockRel(substrate, TiN, 0, subH/2  + buffH/2, 0, simW, buffH, simD)
base      = BlockRel(buffer   , STO, 0, buffH/2 + baseH/2, 0, simW, baseH, simD)
topMatrix = BlockRel(base     , Al2O3, 0, baseH/2 + topH/2 , 0, simW, topH,  simD)
VANs      = FillVANs(topMatrix,  Au, VAN_R, VAN_sp)
wvg       = BlockRel(base     , STO, 0, baseH/2 + wvgH/2 , 0, wvgW, wvgH,  simD)
space     = BlockRel(topMatrix, Vac, 0, wvgH/2  + vaccH/2, 0, wvgW, wvgH,  simD)
geometry  = flatten([substrate, buffer, topMatrix, VANs, base, wvg])

# MAGIC
L = 1.5
sources = [
    mp.Source(
        mp.ContinuousSource(
            wavelength = L,
            width      = 1# 3.3*simD / 10,
        ),
        component = mp.Ex,
        center    = base.center + mp.Vector3(0, wvgH/2, -simD/2 + pmlW * 2),
        size      = mp.Vector3(wvgW, wvgH + baseH, 0)
    )
]
print(f"Cell height: {cell.y}; Source Height: {sources[0].size.y}");

# SIM object

sim = mp.Simulation(
    cell_size           = cell,
    boundary_layers     = pml_layers,
    geometry            = geometry,
    sources             = sources,
    resolution          = resolution
    #output_volume       = mp.Volume(center = mp.Vector3(0, 0, 0), size = mp.Vector3(simW, simH, 0))
)
sim.use_output_directory()

# Collect Data with mp.in_volume fxn
output_slice = mp.Volume(center = mp.Vector3(0, 0, 0)   , size = mp.Vector3(simW, simH, 0))
output_layer = mp.Volume(center = wvg.center            , size = mp.Vector3(simW, 0, simD))

Or = 50
sim.run(
    mp.at_beginning(  mp.in_volume( output_slice, mp.with_prefix("slice_", mp.output_png(mp.Dielectric, "-Zc hot")     ) ) ),
    mp.at_every(L/Or, mp.in_volume( output_slice, mp.with_prefix("slice_", mp.output_png(mp.Ex,         "-Zc bluered") ) ) ),
    mp.at_every(L/Or, mp.in_volume( output_slice, mp.with_prefix("slice_", mp.output_png(mp.Ey,         "-Zc bluered") ) ) ),
    mp.at_every(L/Or, mp.in_volume( output_slice, mp.with_prefix("slice_", mp.output_png(mp.Ez,         "-Zc bluered") ) ) ),
    
    mp.at_beginning(  mp.in_volume( output_layer, mp.with_prefix("layer_", mp.output_png(mp.Dielectric, "-Zc hot")     ) ) ),
    mp.at_every(L/Or, mp.in_volume( output_layer, mp.with_prefix("layer_", mp.output_png(mp.Ex,         "-Zc bluered") ) ) ),
    mp.at_every(L/Or, mp.in_volume( output_layer, mp.with_prefix("layer_", mp.output_png(mp.Ey,         "-Zc bluered") ) ) ),
    mp.at_every(L/Or, mp.in_volume( output_layer, mp.with_prefix("layer_", mp.output_png(mp.Ez,         "-Zc bluered") ) ) ),
    
    until = simD * 3.3 * 3
)
