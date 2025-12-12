#------------------------------------------------------------------------------#
# Fiber direction calculation
# This step1 pseudo-simulation is used to compute the direction vectors of the
# carbon fibers, which is later used as the reference direction to perform a
# rotation of the coordinate system of the thermal conductivity tensor. We align
# the x-direction of the original tensor with the local direction vector of the
# fibers. The diffuse interface is simulataneously generated from the sharp
# binary image used as the initial condition for the fibers.
#------------------------------------------------------------------------------#
lo = 2.3973586e-03 #2.3973586e-3  #2.1524e-04  # micron 
to = 4.3299e-04 # s 
eo = 3.9 # eV
# Av = 6.02214076e23 # avogadro's number
ev = 6.242e18 #conversion from J to EV
#------------------------------------------------------------------------------#
[Mesh]
  # Create a mesh representing the EBSD data
  [ebsd_mesh]
    type = EBSDMeshGenerator
    filename = ../../structure/ExampleFiber_2D_ebsd.txt
    pre_refine = 0
  []
    parallel_type = DISTRIBUTED
    
[]
#------------------------------------------------------------------------------#
[GlobalParams]
  # Interface thickness from Grand Potential material
  # Total interface thickness
  width = 4644 #${fparse 1/lo} #24247 #48494 # int_width half of the total width

  # [Materials] stuff during initialization
  derivative_order = 2
  evalerror_behavior = error
  enable_ad_cache = false
  enable_jit = false
[]

#------------------------------------------------------------------------------#
[Functions]
  # Temperature IC
  [ic_func_Tx]
    type = ParsedFunction
    expression = '(1000-2000)/1673460 * x + 2000' #15518530 ${fparse 120/lo} 
  []
  [ic_func_Ty]
    type = ParsedFunction
    expression = '(1000-2000)/139455 * y + 2000'  #1293210 ${fparse 10/lo}
  []
[]

[UserObjects]
  [ebsd]
    # Read in the EBSD data. Uses the filename given in the mesh block.
    type = EBSDReader
  []
[]

#------------------------------------------------------------------------------#
[ICs]
  [IC_eta_g]
    # Initializes the variable info from the ebsd data
    type = ReconPhaseVarIC
    ebsd_reader = ebsd
    phase = 1
    variable = eta_g
  []
  [IC_eta_f]
    type = ReconPhaseVarIC
    ebsd_reader = ebsd
    phase = 2
    variable = eta_f
  []

  [IC_Tx]
    type = FunctionIC
    variable = T_x
    function = ic_func_Tx
  []
  [IC_Ty]
    type = FunctionIC
    variable = T_y
    function = ic_func_Ty
  []
[]

#------------------------------------------------------------------------------#
[Variables]
  #Phase eta_f: carbon fiber
  [eta_f]
  []
  #Phase eta_g: gas
  [eta_g]
  []

  # Temperatures
  [T_x]
  []
  [T_y]
  []
[]

#------------------------------------------------------------------------------#
# Bnds stuff
[AuxVariables]
  [var_00]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_01]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_02]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []

  [var_10]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_11]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_12]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []

  [var_20]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_21]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [var_22]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [PHASE]
    family = MONOMIAL
    order = CONSTANT
  []
[]

#------------------------------------------------------------------------------#
[AuxKernels]
  [var_00_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_00
    row = 0
    column = 0
    execute_on = 'TIMESTEP_END'
  []
  [var_01_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_01
    row = 0
    column = 1
    execute_on = 'TIMESTEP_END'
  []
  [var_02_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_02
    row = 0
    column = 2
    execute_on = 'TIMESTEP_END'
  []

  [var_10_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_10
    row = 1
    column = 0
    execute_on = 'TIMESTEP_END'
  []
  [var_11_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_11
    row = 1
    column = 1
    execute_on = 'TIMESTEP_END'
  []
  [var_12_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_12
    row = 1
    column = 2
    execute_on = 'TIMESTEP_END'
  []

  [var_20_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_20
    row = 2
    column = 0
    execute_on = 'TIMESTEP_END'
  []
  [var_21_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_21
    row = 2
    column = 1
    execute_on = 'TIMESTEP_END'
  []
  [var_22_aux]
    type = MaterialRealTensorValueAux
    property = thcond_aniso
    variable = var_22
    row = 2
    column = 2
    execute_on = 'TIMESTEP_END'
  []
[]

#------------------------------------------------------------------------------#
#    #  ######  #####   #    #  ######  #        ####
#   #   #       #    #  ##   #  #       #       #
####    #####   #    #  # #  #  #####   #        ####
#  #    #       #####   #  # #  #       #            #
#   #   #       #   #   #   ##  #       #       #    #
#    #  ######  #    #  #    #  ######  ######   ####
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
[Kernels]
  #----------------------------------------------------------------------------#
  # eta_f kernels
  [AC_f_bulk]
    type = ACGrGrMulti
    variable = eta_f
    v = 'eta_g'
    gamma_names = 'gamma_fg'
    mob_name = L
  []

  [AC_f_sw]
    type = ACSwitching
    variable = eta_f
    Fj_names = 'omega_f omega_g'
    hj_names = 'h_f     h_g'
    mob_name = L
    coupled_variables = 'eta_g'
  []

  [AC_f_int]
    type = ACInterface
    variable = eta_f
    kappa_name = kappa
    mob_name = L
    coupled_variables = 'eta_g'
  []

  [eta_f_dot]
    type = TimeDerivative
    variable = eta_f
  []

  #----------------------------------------------------------------------------#
  # eta_g kernels
  [AC_g_bulk]
    type = ACGrGrMulti
    variable = eta_g
    v = 'eta_f'
    gamma_names = 'gamma_fg'
    mob_name = L
  []

  [AC_g_sw]
    type = ACSwitching
    variable = eta_g
    Fj_names = 'omega_f omega_g'
    hj_names = 'h_f     h_g'
    mob_name = L
    coupled_variables = 'eta_f'
  []

  [AC_g_int]
    type = ACInterface
    variable = eta_g
    kappa_name = kappa
    mob_name = L
    coupled_variables = 'eta_f'
  []

  [eta_g_dot]
    type = TimeDerivative
    variable = eta_g
  []

  #----------------------------------------------------------------------------#
  # Heat Conduction kernels
  [Heat_Conduction_Tx]
    type = HeatConduction
    variable = T_x
    diffusion_coefficient = thermal_conductivity
  []

  [Heat_Conduction_Ty]
    type = HeatConduction
    variable = T_y
    diffusion_coefficient = thermal_conductivity
  []
[]

#----------------------------------------------------------------------------#
# END OF KERNELS

#------------------------------------------------------------------------------#
#    #    ##    #####  ######  #####   #    ##    #        ####
##  ##   #  #     #    #       #    #  #   #  #   #       #
# ## #  #    #    #    #####   #    #  #  #    #  #        ####
#    #  ######    #    #       #####   #  ######  #            #
#    #  #    #    #    #       #   #   #  #    #  #       #    #
#    #  #    #    #    ######  #    #  #  #    #  ######   ####
#------------------------------------------------------------------------------#
[Materials]
  #----------------------------------------------------------------------------#
  # Switching functions
  [switch_f]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_f
    all_etas = 'eta_f eta_g'
    phase_etas = 'eta_f'

    outputs = exodus
    output_properties = h_f
  []

  [switch_g]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_g
    all_etas = 'eta_f eta_g'
    phase_etas = 'eta_g'

    outputs = exodus
    output_properties = h_g
  []

  #----------------------------------------------------------------------------#
  # Grand potential densities
  [omega_f]
    type = DerivativeParsedMaterial
    property_name = omega_f
    expression = '1e-5'
  []

  [omega_g]
    type = DerivativeParsedMaterial
    property_name = omega_g
    expression = '1e-5'
  []

  #----------------------------------------------------------------------------#
  [phase_mobility]
    type = GenericConstantMaterial

    prop_names = 'L'
    prop_values = '1e3'
  []

  #----------------------------------------------------------------------------#
  # Grand Potential Interface Parameters
  [iface]
    type = GrandPotentialInterface
    gamma_names = 'gamma_fg'
    sigma = '0.01'
    kappa_name = kappa
    mu_name = mu
    # width = 4644
    outputs = exodus
  []

  #------------------------------------------------------------------------------#
  # Conservation check
  [sum_eta]
    type = ParsedMaterial
    property_name = sum_eta
    coupled_variables = 'eta_f eta_g'

    expression = 'eta_f + eta_g'
    outputs = exodus
  []

  [sum_h]
    type = DerivativeParsedMaterial
    property_name = sum_h
    coupled_variables = 'eta_f eta_g'

    expression = 'h_f + h_g'

    material_property_names = 'h_f h_g'
    outputs = exodus
  []

  #------------------------------------------------------------------------------#
  [thermal_conductivity]
    type = DerivativeParsedMaterial
    property_name = thermal_conductivity
    coupled_variables = 'eta_f eta_g'

    expression = 'h_f*100.0 + h_g*1.0'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
    outputs = exodus
  []

  [th_cond_AF]
    type = DerivativeParsedMaterial
    property_name = th_cond_AF
    coupled_variables = 'eta_f eta_g'

    expression = 'h_f*100.0 + h_g*0.0'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
    outputs = exodus
  []

  #------------------------------------------------------------------------------#
  # Tensor Transformation #
  #------------------------------------------------------------------------------#
  # FiberDirection transforms the temperature gradient into the normalized fiber direction
  [direction_AF]
    type = FiberDirectionAF
    temp_x = T_x
    temp_y = T_y

    thermal_conductivity = th_cond_AF
    vector_name = fiber_direction_AF

    correct_negative_directions = false
    angle_tol = 60
    norm_tol = 1
    outputs = exodus
  []

  # MobilityRotationVector calculates the transformed tensor given the fiber direction
  [transformation]
    type = MobilityRotationVector
    M_A = thcond_f
    direction_vector = fiber_direction_AF
    M_name = rot_thcond_f
    outputs = exodus
  []
  #----------------------------------------------------------------------------#
  # Thermal conductivity
  # In step 1, the value with the longitudinal thermal conductivity is ii
  [thcond_f]
    type = ConstantAnisotropicMobility
    tensor = '${fparse 50*lo*ev*to/(1e6*eo)}    0                                   0
              0                                 ${fparse 0.5*lo*ev*to/(1e6*eo)}     0
              0                                 0                                   ${fparse 0.5*lo*ev*to/(1e6*eo)}'

    # tensor = '7.4576e+06      0             0
    #           0               7.4576e+04    0
    #           0               0             7.4576e+04'

    M_name = thcond_f
  []

  # In step 1, thcond_g should be all zeros
  [thcond_g]
    type = ConstantAnisotropicMobility
    tensor = '0      0    0
              0      0    0
              0      0    0'

    M_name = thcond_g
  []

  # Creates a compound tensor for the entire domain
  [thcond_composite]
    type = CompositeMobilityTensor
    coupled_variables = 'eta_f eta_g'

    weights = 'h_f            h_g'
    tensors = 'rot_thcond_f   thcond_g'

    M_name = thcond_aniso
    outputs = exodus
  []

[] # End of Materials

#------------------------------------------------------------------------------#
[BCs]
  [Tx_left]
    type = DirichletBC
    variable = T_x
    boundary = 'left'
    value = 2000
  []
  [Tx_right]
    type = DirichletBC
    variable = T_x
    boundary = 'right'
    value = 1000
  []

  [Ty_bottom]
    type = DirichletBC
    variable = T_y
    boundary = 'bottom'
    value = 2000
  []
  [Ty_top]
    type = DirichletBC
    variable = T_y
    boundary = 'top'
    value = 1000
  []
[]

#------------------------------------------------------------------------------#
[Preconditioning]
  active = 'hypre'

  [hypre]
    type = SMP
    full = true
    solve_type = NEWTON
    petsc_options_iname = '-pc_type  -pc_hypre_type  -ksp_gmres_restart  -pc_hypre_boomeramg_strong_threshold'
    petsc_options_value = 'hypre     boomeramg       31                  0.7'
  []
[]

#---------------------------------------------------------------------------------------------#
#######  #     #  #######   #####   #     #  #######  ###  #######  #     #  #######  ######
#         #   #   #        #     #  #     #     #      #   #     #  ##    #  #        #     #
#          # #    #        #        #     #     #      #   #     #  # #   #  #        #     #
#####       #     #####    #        #     #     #      #   #     #  #  #  #  #####    ######
#          # #    #        #        #     #     #      #   #     #  #   # #  #        #   #
#         #   #   #        #     #  #     #     #      #   #     #  #    ##  #        #    #
#######  #     #  #######   #####    #####      #     ###  #######  #     #  #######  #     #
#---------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------#
[Executioner]
  type = Transient

  nl_max_its = 12
  nl_rel_tol = 1.0e-8

  l_max_its = 30
  l_tol = 1.0e-8

  start_time = 0.0
  end_time = 200


  dtmin = 1e-10

  # verbose = true

  automatic_scaling = true
  compute_scaling_once = false

  line_search = basic
  line_search_package = petsc

  scheme = bdf2

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1

    # growth_factor = 1.2
    # cutback_factor = 0.83333

    optimal_iterations = 6 # Number of nonlinear
    # linear_iteration_ratio = 10 # Ratio of linear to nonlinear

    # iteration_window = 0
  []
[]

#------------------------------------------------------------------------------#
#####    ####    ####   #####
#    #  #    #  #         #
#    #  #    #   ####     #
#####   #    #       #    #
#       #    #  #    #    #
#        ####    ####     #
#------------------------------------------------------------------------------#
[Postprocessors]
  # Species output
  [int_h_f]
    type = ElementIntegralMaterialProperty
    mat_prop = h_f
    execute_on = 'TIMESTEP_END FINAL'

    allow_duplicate_execution_on_initial = true

    outputs = 'exodus console'
  []

  #----------------------------------------------------------------------------#
  # Stats
  [dt]
    type = TimestepSize
  []
  [alive_time]
    type = PerfGraphData
    data_type = TOTAL
    section_name = 'Root'
  []
  [mem_total_physical_mb]
    type = MemoryUsage
    mem_type = physical_memory
    mem_units = megabytes
    value_type = total
  []
  [mem_max_physical_mb]
    type = MemoryUsage
    mem_type = physical_memory
    mem_units = megabytes
    value_type = max_process
  []
[]

#------------------------------------------------------------------------------#
[Outputs]
  [console]
    type = Console
    fit_mode = 160
    max_rows = 10
  []

  [exodus]
    type = Exodus
  []

  [csv]
    type = CSV
  []

  [pgraph]
    type = PerfGraphOutput
    execute_on = 'final'
    level = 2
    heaviest_branch = true
    heaviest_sections = 2
  []
[]

#------------------------------------------------------------------------------#
# [Debug]
#   show_var_residual_norms = true
# []