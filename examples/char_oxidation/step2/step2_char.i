#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  [gen]
    type = DistributedRectilinearMeshGenerator
    dim = 2

    xmin = 0
    xmax = 464400 # 100 microns
    nx = 100

    ymin = 0
    ymax = 464400 # 100 microns
    ny = 100

    elem_type = QUAD4
  []

  uniform_refine = 0
[]

#------------------------------------------------------------------------------#
[GlobalParams]
  # Interface thickness for the grand potential material
  width = 4644 # int_width 1 micron, half of the total width

  # [Materials] stuff during initialization
  derivative_order = 2
  evalerror_behavior = error
  enable_ad_cache = false
  enable_jit = false
[]

#------------------------------------------------------------------------------#
[UserObjects]
  [solution_uo]
    type = SolutionUserObject
    mesh = ../step1/step1_char_out.e
    system_variables = 'eta_f'

    timestep = 'LATEST'
  []
[]

#------------------------------------------------------------------------------#
[Variables]
  #Phase alpha: carbon fiber
  [eta_f]
  []
  #Phase beta: char
  [eta_c]
  []
  #Phase gamma: gas
  [eta_g]
  []
[]

#------------------------------------------------------------------------------#
[Functions]
  [ic_func_eta_f]
    type = SolutionFunction
    from_variable = eta_f
    solution = solution_uo
  []
[]

#------------------------------------------------------------------------------#
[ICs]
  [IC_eta_f]
    type = FunctionIC
    variable = eta_f
    function = ic_func_eta_f
  []

  [IC_eta_c]
    type = MultiSmoothCircleIC
    variable = eta_c

    numbub = 27
    # radius = 23220 # 5 microns
    radius = 32508 # 7 microns
    bubspac = 69660 # 15 microns


    radius_variation = 4644
    radius_variation_type = normal

    invalue = 0.0
    outvalue = 1.0

    profile = TANH
    int_width = 4644

    rand_seed = 276457
  []

  [IC_eta_g]
    type = MultiSmoothCircleIC
    variable = eta_g

    numbub = 27
    # radius = 23220 # 5 microns
    radius = 32508 # 7 microns
    bubspac = 69660 # 15 microns


    radius_variation = 4644
    radius_variation_type = normal

    invalue = 1.0
    outvalue = 0.0

    profile = TANH
    int_width = 4644

    rand_seed = 276457
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
  [eta_f_empty]
    type = NullKernel
    variable = eta_f
  []

  #----------------------------------------------------------------------------#
  # eta_c kernels
  [AC_c_bulk]
    type = ACGrGrMulti
    variable    = eta_c
    v           = 'eta_f  eta_g'
    gamma_names = 'gamma_fc    gamma_cg'
    mob_name    = L
  []

  [AC_c_sw]
    type = ACSwitching
    variable  = eta_c
    Fj_names  = 'omega_f  omega_c  omega_g'
    hj_names  = 'h_f      h_c      h_g'
    mob_name  = L
    coupled_variables      = 'eta_f eta_g'
  []

  [AC_c_int]
    type = ACInterface
    variable   = eta_c
    kappa_name = kappa
    mob_name   = L
    coupled_variables       = 'eta_f  eta_g'
  []

  [eta_c_dot]
    type = TimeDerivative
    variable = eta_c
  []

  #----------------------------------------------------------------------------#
  # eta_g kernels
  [AC_g_bulk]
    type = ACGrGrMulti
    variable    = eta_g
    v           = 'eta_f  eta_c'
    gamma_names = 'gamma_fg    gamma_cg'
    mob_name    = L
  []

  [AC_g_sw]
    type = ACSwitching
    variable  = eta_g
    Fj_names  = 'omega_f  omega_c  omega_g'
    hj_names  = 'h_f      h_c      h_g'
    mob_name  = L
    coupled_variables      = 'eta_f eta_c'
  []

  [AC_g_int]
    type = ACInterface
    variable    = eta_g
    kappa_name  = kappa
    mob_name    = L
    coupled_variables        = 'eta_f  eta_c'
  []

  [eta_g_dot]
    type = TimeDerivative
    variable = eta_g
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
    all_etas = 'eta_f eta_c eta_g'
    phase_etas = 'eta_f'

    outputs = exodus
    output_properties = h_f
  []

  [switch_c]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_c
    all_etas = 'eta_f eta_c eta_g'
    phase_etas = 'eta_c'

    outputs = exodus
    output_properties = h_c
  []

  [switch_g]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_g
    all_etas = 'eta_f eta_c eta_g'
    phase_etas = 'eta_g'

    outputs = exodus
    output_properties = h_g
  []

  #----------------------------------------------------------------------------#
  # Grand potential densities
  [omega_f]
    type = DerivativeParsedMaterial
    property_name = omega_f
    expression =  '1e-5'
  []

  [omega_c]
    type = DerivativeParsedMaterial
    property_name = omega_c
    expression =  '1e-5'
  []

  [omega_g]
    type = DerivativeParsedMaterial
    property_name = omega_g
    expression =  '1e-5'
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
    gamma_names = 'gamma_fc          gamma_fg           gamma_cg'

    sigma       = '1.4829e-02   1.4829e-02    1.4829e-02' # = 0.2 J/m2

    kappa_name = kappa
    mu_name = mu

    sigma_index = 0
  []

  #------------------------------------------------------------------------------#
  # Conservation check
  [sum_eta]
    type = ParsedMaterial
    property_name = sum_eta
    coupled_variables = 'eta_f eta_c eta_g'

    expression =  'eta_f + eta_c + eta_g'

    outputs = exodus
    output_properties = sum_eta
  []

  [sum_h]
    type = ParsedMaterial
    property_name = sum_h

    expression =  'h_f + h_c + h_g'

    material_property_names = 'h_f h_c h_g'

    outputs = exodus
    output_properties = sum_h
  []
[]

#------------------------------------------------------------------------------#
[BCs]
  [gas_top]
    type = DirichletBC
    variable = 'eta_g'
    boundary = 'top'
    value = '1.0'
  []

  [not_char_top]
    type = DirichletBC
    variable = 'eta_c'
    boundary = 'top'
    value = '0.0'
  []
[]

#------------------------------------------------------------------------------#
[Preconditioning]
  active = 'hypre'

  [hypre]
    type = SMP
    full = true
    solve_type = NEWTON
    petsc_options_iname = '-pc_type  -pc_hypre_type  -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
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
[Executioner]
  type = Transient

  nl_max_its = 12
  nl_rel_tol = 1.0e-8

  l_max_its = 30
  l_tol = 1.0e-6

  start_time = 0.0

  dtmin = 1e-6
  dtmax = 100
  end_time = 170

  # verbose = true

  automatic_scaling = true
  compute_scaling_once = false

  line_search = default
  line_search_package = petsc

  scheme = bdf2

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1

    growth_factor = 1.2
    cutback_factor = 0.83333

    optimal_iterations = 6
    linear_iteration_ratio = 10

    iteration_window = 0
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
#------------------------------------------------------------------------------#
[Postprocessors]
  # Area
  [int_h_f]
    type = ElementIntegralMaterialProperty
    mat_prop = h_f

    outputs = 'csv exodus console'
  []

  [int_h_c]
    type = ElementIntegralMaterialProperty
    mat_prop = h_c

    outputs = 'csv exodus console'
  []

  [int_h_g]
    type = ElementIntegralMaterialProperty
    mat_prop = h_g

    outputs = 'csv exodus console'
  []

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
  file_base = step2_char_out

  [console]
    type = Console
    fit_mode = 80
    max_rows = 10
  []

  [exodus]
    type = Exodus
    execute_on = 'TIMESTEP_END'
  []

  [csv]
    type = CSV
    execute_on = 'TIMESTEP_END'
  []

  [pgraph]
    type = PerfGraphOutput
    execute_on = 'final'
    level = 1
    heaviest_branch = true
    heaviest_sections = 9
  []
[]

#------------------------------------------------------------------------------#
# [Debug]
#   show_var_residual_norms = true
# []
