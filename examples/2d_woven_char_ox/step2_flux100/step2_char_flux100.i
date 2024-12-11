#------------------------------------------------------------------------------#
# step3: 2D char oxidation
# Nondimensional parameters with convertion factors:
# lo = 2.1524e-04 micron
# to = 4.3299e-04 s
# eo = 3.9 eV
#
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  # Create a mesh representing the EBSD data
  [ebsd_mesh]
    type = EBSDMeshGenerator
    filename = ../structure/CharOxOB_2D_ebsd.txt
  []
    parallel_type = DISTRIBUTED
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
  [solution_uo] # Transfer the thermal conductivity tensor
    type = SolutionUserObject
    mesh = ../step1/step1_char_out.e
    system_variables = 'eta_f eta_c eta_g
                        var_00 var_01 var_02
                        var_10 var_11 var_12
                        var_20 var_21 var_22'
    timestep = 'LATEST'
  []

  # [solution_uo_step2] # Transfer ICs
  #   type = SolutionUserObject
  #   mesh = ../step2/step2_char_out.e
  #   system_variables = 'eta_f eta_c eta_g'

  #   timestep = 'LATEST'
  # []

  [detect_char]
    type = Terminator
    expression = 'int_h_c < 1e6'
  []
  [ebsd]
    # Read in the EBSD data. Uses the filename given in the mesh block.
    type = EBSDReader
  []
[]

#------------------------------------------------------------------------------#
[Variables]
  # Chemical potential of carbon (C)
  [w_c]
  []
  # Chemical potential of oxygen (O)
  [w_o]
  []
  # Chemical potential of carbon monoxide (CO)
  [w_co]
  []

  #Phase eta_f: carbon fiber
  [eta_f]
  []
  #Phase eta_c: char
  [eta_c]
  []
  #Phase eta_g: gas
  [eta_g]
  []

  # Temperature
  [T]
  []
[]

#------------------------------------------------------------------------------#
[Functions]
  [ic_func_T]
    type = ParsedFunction
    expression = '(T_top - T_bottom)/l_domain * y + T_bottom' # Tchange

    symbol_names = 'T_bottom  T_top   l_domain'
    symbol_values = '2990      3000    464400' # 100 microns
  []

  [ic_func_eta_f]
    type = SolutionFunction
    from_variable = eta_f
    solution = solution_uo
  []
  [ic_func_eta_c]
    type = SolutionFunction
    from_variable = eta_c
    solution = solution_uo
  []
  [ic_func_eta_g]
    type = SolutionFunction
    from_variable = eta_g
    solution = solution_uo
  []

  [ic_func_w_o]
    type = SolutionFunction
    from_variable = eta_g
    solution = solution_uo
    scale_factor = -9.9899e-07
  []

  [T_fiber_func]
    type = ParsedFunction
    expression = 'T_fiber_pp / (int_h_f)'
    symbol_names = 'T_fiber_pp int_h_f'
    symbol_values = 'T_fiber_pp int_h_f'
  []

  [T_char_func]
    type = ParsedFunction
    expression = 'T_char_pp / (int_h_c)'
    symbol_names = 'T_char_pp int_h_c'
    symbol_values = 'T_char_pp int_h_c'
  []

  [ic_func_00]
    type = SolutionFunction
    from_variable = var_00
    solution = solution_uo
  []
  [ic_func_01]
    type = SolutionFunction
    from_variable = var_01
    solution = solution_uo
  []
  [ic_func_02]
    type = SolutionFunction
    from_variable = var_02
    solution = solution_uo
  []

  [ic_func_10]
    type = SolutionFunction
    from_variable = var_10
    solution = solution_uo
  []
  [ic_func_11]
    type = SolutionFunction
    from_variable = var_11
    solution = solution_uo
  []
  [ic_func_12]
    type = SolutionFunction
    from_variable = var_12
    solution = solution_uo
  []

  [ic_func_20]
    type = SolutionFunction
    from_variable = var_20
    solution = solution_uo
  []
  [ic_func_21]
    type = SolutionFunction
    from_variable = var_21
    solution = solution_uo
  []
  [ic_func_22]
    type = SolutionFunction
    from_variable = var_22
    solution = solution_uo
  []
[]

#------------------------------------------------------------------------------#
[ICs]
  # Fiber
  [IC_eta_f]
    type = FunctionIC
    variable = eta_f
    function = ic_func_eta_f
  []

  # Char
  [IC_eta_c]
    type = FunctionIC
    variable = eta_c
    function = ic_func_eta_c
  []

  # Gas
  [IC_eta_g]
    type = FunctionIC
    variable = eta_g
    function = ic_func_eta_g
  []

  # Carbon
  [IC_w_c]
    type = ConstantIC
    variable = w_c
    value = 0
  []

  # Oxygen
  # [IC_w_o]
  #   type = ConstantIC
  #   variable = w_o
  #   value = 0
  # []
  [IC_w_o]
    type = FunctionIC
    variable = w_o
    function = ic_func_w_o
  []

  #Carbon Monoxide
  [IC_w_co]
    type = ConstantIC
    variable = w_co
    value = 0
  []

  # Temperature
  [IC_T]
    type = ConstantIC
    variable = T
    value = 3000
  []

  [IC_00]
    type = FunctionIC
    variable = var_00
    function = ic_func_00
  []
  [IC_01]
    type = FunctionIC
    variable = var_01
    function = ic_func_01
  []
  [IC_02]
    type = FunctionIC
    variable = var_02
    function = ic_func_02
  []

  [IC_10]
    type = FunctionIC
    variable = var_10
    function = ic_func_10
  []
  [IC_11]
    type = FunctionIC
    variable = var_11
    function = ic_func_11
  []
  [IC_12]
    type = FunctionIC
    variable = var_12
    function = ic_func_12
  []

  [IC_20]
    type = FunctionIC
    variable = var_20
    function = ic_func_20
  []
  [IC_21]
    type = FunctionIC
    variable = var_21
    function = ic_func_21
  []
  [IC_22]
    type = FunctionIC
    variable = var_22
    function = ic_func_22
  []
[]

#------------------------------------------------------------------------------#
[AuxVariables]
  [T_fiber_var]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 3000 # Tchange
  []

  [T_char_var]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 3000 # Tchange
  []

  [var_00]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_01]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_02]
    order = CONSTANT
    family = MONOMIAL
  []

  [var_10]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_11]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_12]
    order = CONSTANT
    family = MONOMIAL
  []

  [var_20]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_21]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_22]
    order = CONSTANT
    family = MONOMIAL
  []

[]

#------------------------------------------------------------------------------#
[AuxKernels]
  [aux_T_fiber]
    type = FunctionAux
    function = T_fiber_func
    variable = T_fiber_var
  []

  [aux_T_char]
    type = FunctionAux
    function = T_char_func
    variable = T_char_var
  []

[] # End of AuxKernels

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
  # Chemical reaction
  [reaction_kernel_C]
    type = MaskedBodyForce
    variable = w_c
    mask = reaction_CO
    coupled_variables = 'w_o w_c w_co eta_f eta_c eta_g T'
  []

  [reaction_kernel_O]
    type = MaskedBodyForce
    variable = w_o
    mask = reaction_CO
    coupled_variables = 'w_o w_c w_co eta_f eta_c eta_g T'
  []

  [reaction_kernel_CO]
    type = MaskedBodyForce
    variable = w_co
    mask = production_CO
    coupled_variables = 'w_o w_c w_co eta_f eta_c eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Endothermic Reaction
  [reaction_energy_CO]
    type = MaskedBodyForce
    variable = T
    mask = energy_CO
    coupled_variables = 'w_o w_c w_co eta_f eta_c eta_g T'
  []

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
    coupled_variables        = 'eta_f eta_c eta_g T'
  []

  [AC_c_sw]
    type = ACSwitching
    variable  = eta_c
    Fj_names  = 'omega_f  omega_c  omega_g'
    hj_names  = 'h_f      h_c      h_g'
    mob_name  = L
    coupled_variables      = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  [AC_c_int]
    type = ACInterface
    variable   = eta_c
    kappa_name = kappa
    mob_name   = L
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
    coupled_variables        = 'eta_f eta_c eta_g T'
  []

  [AC_g_sw]
    type = ACSwitching
    variable  = eta_g
    Fj_names  = 'omega_f  omega_c  omega_g'
    hj_names  = 'h_f      h_c      h_g'
    mob_name  = L
    coupled_variables      = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  [AC_g_int]
    type = ACInterface
    variable    = eta_g
    kappa_name  = kappa
    mob_name    = L
  []

  [eta_g_dot]
    type = TimeDerivative
    variable = eta_g
  []

  #----------------------------------------------------------------------------#
  # Chemical potential kernels
  #----------------------------------------------------------------------------#
  # Carbon
  [w_c_dot]
    type = SusceptibilityTimeDerivative
    variable = w_c
    f_name = chi_c
    coupled_variables = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  [diffusion_c]
    type = MatDiffusion
    variable = w_c
    diffusivity = Dchi_c
    args = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Oxygen
  [w_o_dot]
    type = SusceptibilityTimeDerivative
    variable = w_o
    f_name = chi_o
    coupled_variables = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  [diffusion_o]
    type = MatDiffusion
    variable = w_o
    diffusivity = Dchi_o
    args = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Carbon Monoxide
  [w_co_dot]
    type = SusceptibilityTimeDerivative
    variable = w_co
    f_name = chi_co
    coupled_variables = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  [diffusion_co]
    type = MatDiffusion
    variable = w_co
    diffusivity = Dchi_co
    args = 'w_c w_o w_co eta_f eta_c eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Coupled kernels
  #----------------------------------------------------------------------------#
  # Carbon
  [coupled_eta_fdot_c]
    type = CoupledSwitchingTimeDerivative
    variable  = w_c
    v         = eta_f
    Fj_names  = 'rho_c_f  rho_c_c  rho_c_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  [coupled_eta_cdot_c]
    type = CoupledSwitchingTimeDerivative
    variable  = w_c
    v         = eta_c
    Fj_names  = 'rho_c_f  rho_c_c  rho_c_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  [coupled_eta_gdot_c]
    type = CoupledSwitchingTimeDerivative
    variable  = w_c
    v         = eta_g
    Fj_names  = 'rho_c_f  rho_c_c  rho_c_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  #----------------------------------------------------------------------------#
  # Oxygen
  [coupled_eta_fdot_o]
    type = CoupledSwitchingTimeDerivative
    variable  = w_o
    v         = eta_f
    Fj_names  = 'rho_o_f  rho_o_c  rho_o_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  [coupled_eta_cdot_o]
    type = CoupledSwitchingTimeDerivative
    variable  = w_o
    v         = eta_c
    Fj_names  = 'rho_o_f  rho_o_c  rho_o_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  [coupled_eta_gdot_o]
    type = CoupledSwitchingTimeDerivative
    variable  = w_o
    v         = eta_g
    Fj_names  = 'rho_o_f  rho_o_c  rho_o_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  #----------------------------------------------------------------------------#
  # Carbon Monoxide
  [coupled_eta_fdot_co]
    type = CoupledSwitchingTimeDerivative
    variable  = w_co
    v         = eta_f
    Fj_names  = 'rho_co_f  rho_co_c  rho_co_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  [coupled_eta_cdot_co]
    type = CoupledSwitchingTimeDerivative
    variable  = w_co
    v         = eta_c
    Fj_names  = 'rho_co_f  rho_co_c  rho_co_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  [coupled_eta_gdot_co]
    type = CoupledSwitchingTimeDerivative
    variable  = w_co
    v         = eta_g
    Fj_names  = 'rho_co_f  rho_co_c  rho_co_g'
    hj_names  = 'h_f      h_c      h_g'
    coupled_variables      = 'eta_f eta_c eta_g w_c w_o w_co T'
  []

  #----------------------------------------------------------------------------#
  # Heat Conduction kernels
  [Heat_Conduction]
    type = MatAnisoDiffusion
    variable = T
    args = 'eta_f eta_c eta_g'

    diffusivity = thcond_aniso
  []

  [Heat_Time_Derivative]
    type = SpecificHeatConductionTimeDerivative
    variable = T
    coupled_variables = 'eta_f eta_c eta_g'

    density = density
    specific_heat = specific_heat
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
  # Reaction expressions
  [CO_reaction_production]
    type = DerivativeParsedMaterial
    property_name = production_CO
    coupled_variables = 'w_c w_o eta_f eta_c eta_g T'

    expression = 'if(rho_c>K_tol&rho_o>K_tol,K_CO*rho_c*rho_o,0)'

    material_property_names = 'K_CO(eta_f,eta_c,eta_g,T) rho_c(w_c,eta_f,eta_c,eta_g) rho_o(w_o,eta_f,eta_c,eta_g) K_tol'

    outputs = exodus
    output_properties = production_CO
  []

  [CO_reaction_consumption]
    type = DerivativeParsedMaterial
    property_name = reaction_CO
    coupled_variables = 'w_c w_o eta_f eta_c eta_g T'

    expression = 'if(rho_c>K_tol&rho_o>K_tol,-K_CO*rho_c*rho_o,0)'

    material_property_names = 'K_CO(eta_f,eta_c,eta_g,T) rho_c(w_c,eta_f,eta_c,eta_g) rho_o(w_o,eta_f,eta_c,eta_g) K_tol'
  []

  #----------------------------------------------------------------------------#
  # Endothermic Reaction Energy
  [CO_reaction_energy]
    type = DerivativeParsedMaterial
    property_name = energy_CO
    coupled_variables = 'w_c w_o eta_f eta_c eta_g T'

    expression = 'if(rho_c>K_tol&rho_o>K_tol,-dH*K_CO*rho_c*rho_o,0)'

    constant_names = 'dH'

    constant_expressions = '2.6575e-01' # = 100 kJ/mol

    material_property_names = 'K_CO(eta_f,eta_c,eta_g,T) rho_c(w_c,eta_f,eta_c,eta_g) rho_o(w_o,eta_f,eta_c,eta_g) K_tol'
  []

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
  # Solid phases: dilute solution model
  # Fiber
  [omega_f]
    type = DerivativeParsedMaterial
    property_name = omega_f
    coupled_variables = 'w_c w_o w_co'

    expression = '-w_c/Va -k_b*To/Va * exp(-(w_c+Ef_v_f)/(k_b*To))
                -k_b*To/Va * exp((w_o-Ef_o_f)/(k_b*To))
                -k_b*To/Va * exp((w_co-Ef_co_f)/(k_b*To))'

    material_property_names = 'To k_b Va Ef_o_f Ef_co_f Ef_v_f'
  []

  # Char
  [omega_c]
    type = DerivativeParsedMaterial
    property_name = omega_c
    coupled_variables = 'w_c w_o w_co'

    expression = '-w_c/Va -k_b*To/Va * exp(-(w_c+Ef_v_c)/(k_b*To))
                -k_b*To/Va * exp((w_o-Ef_o_c)/(k_b*To))
                -k_b*To/Va * exp((w_co-Ef_co_c)/(k_b*To))'

    material_property_names = 'To k_b Va Ef_o_c Ef_co_c Ef_v_c'
  []

  # Gas
  [omega_g]
    type = DerivativeParsedMaterial
    property_name = omega_g
    coupled_variables = 'w_c w_o w_co'

    expression = '-1/2*w_c^2/(Va^2*A_c_g) -w_c*xeq_c_g/Va
                -1/2*w_o^2/(Va^2*A_o_g) -w_o*xeq_o_g/Va
                -1/2*w_co^2/(Va^2*A_co_g) -w_co*xeq_co_g/Va'

    material_property_names = 'Va A_o_g A_c_g A_co_g xeq_o_g xeq_c_g xeq_co_g'
  []

  [omega]
    type = DerivativeParsedMaterial
    property_name = omega
    coupled_variables = 'w_c w_o w_co eta_f eta_c eta_g'

    expression = 'h_f*omega_f + h_c*omega_c + h_g*omega_g'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              omega_f(w_c,w_o,w_co) omega_c(w_c,w_o,w_co) omega_g(w_c,w_o,w_co)'
  []

  #----------------------------------------------------------------------------#
  # CARBON
  [rho_c_f]
    type = DerivativeParsedMaterial
    property_name = rho_c_f
    coupled_variables = 'w_c'

    expression = '1/Va*(1 - exp(-(w_c+Ef_v_f)/(k_b*To)))' # Dilute Sol

    material_property_names = 'To Va Ef_v_f k_b'
  []

  [rho_c_c]
    type = DerivativeParsedMaterial
    property_name = rho_c_c
    coupled_variables = 'w_c'

    expression = '1/Va*(1 - exp(-(w_c+Ef_v_c)/(k_b*To)))' # Dilute Sol

    material_property_names = 'To Va Ef_v_c k_b'
  []

  [rho_c_g]
    type = DerivativeParsedMaterial
    property_name = rho_c_g
    coupled_variables = 'w_c'

    expression = '1/Va*(w_c/(Va*A_c_g) + xeq_c_g)' # Parabolic

    material_property_names = 'Va A_c_g xeq_c_g'
  []

  [rho_c]
    type = DerivativeParsedMaterial
    property_name = rho_c
    coupled_variables = 'w_c eta_f eta_c eta_g'

    expression = 'h_f*rho_c_f + h_c*rho_c_c + h_g*rho_c_g'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              rho_c_f(w_c) rho_c_c(w_c) rho_c_g(w_c)'
  []

  [x_c]
    type = DerivativeParsedMaterial
    property_name = x_c
    coupled_variables = 'w_c eta_f eta_c eta_g'

    expression = 'Va*(h_f*rho_c_f + h_c*rho_c_c +h_g*rho_c_g)'

    material_property_names = 'Va h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              rho_c_f(w_c) rho_c_c(w_c) rho_c_g(w_c)'

    outputs = exodus
    output_properties = x_c
  []

  #----------------------------------------------------------------------------#
  # OXYGEN
  [rho_o_f]
    type = DerivativeParsedMaterial
    property_name = rho_o_f
    coupled_variables = 'w_o'

    expression = '1/Va * exp((w_o-Ef_o_f)/(k_b*To))' # Dilute Sol

    material_property_names = 'To Va Ef_o_f k_b'
  []

  [rho_o_c]
    type = DerivativeParsedMaterial
    property_name = rho_o_c
    coupled_variables = 'w_o'

    expression = '1/Va * exp((w_o-Ef_o_c)/(k_b*To))' # Dilute Sol

    material_property_names = 'To Va Ef_o_c k_b'
  []

  [rho_o_g]
    type = DerivativeParsedMaterial
    property_name = rho_o_g
    coupled_variables = 'w_o'

    expression = '1/Va*(w_o/(Va*A_o_g) + xeq_o_g)' # Parabolic

    material_property_names = 'Va A_o_g xeq_o_g'
  []

  [rho_o]
    type = DerivativeParsedMaterial
    property_name = rho_o
    coupled_variables = 'w_o eta_f eta_c eta_g'

    expression = 'h_f*rho_o_f + h_c*rho_o_c + h_g*rho_o_g'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              rho_o_f(w_o) rho_o_c(w_o) rho_o_g(w_o)'
  []

  [x_o]
    type = DerivativeParsedMaterial
    property_name = x_o
    coupled_variables = 'w_o eta_f eta_c eta_g'

    expression = 'Va*(h_f*rho_o_f + h_c*rho_o_c + h_g*rho_o_g)'

    material_property_names = 'Va h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              rho_o_f(w_o) rho_o_c(w_o) rho_o_g(w_o)'

    outputs = exodus
    output_properties = x_o
  []

  #----------------------------------------------------------------------------#
  # CARBON MONOXIDE
  [rho_co_f]
    type = DerivativeParsedMaterial
    property_name = rho_co_f
    coupled_variables = 'w_co'

    expression = '1/Va * exp((w_co-Ef_co_f)/(k_b*To))' # Dilute Sol

    material_property_names = 'To Va Ef_co_f k_b'
  []

  [rho_co_c]
    type = DerivativeParsedMaterial
    property_name = rho_co_c
    coupled_variables = 'w_co'

    expression = '1/Va * exp((w_co-Ef_co_c)/(k_b*To))' # Dilute Sol

    material_property_names = 'To Va Ef_co_c k_b'
  []

  [rho_co_g]
    type = DerivativeParsedMaterial
    property_name = rho_co_g
    coupled_variables = 'w_co'

    expression = '1/Va*(w_co/(Va*A_co_g) + xeq_co_g)' # Parabolic

    material_property_names = 'Va A_co_g xeq_co_g'
  []

  [rho_co]
    type = DerivativeParsedMaterial
    property_name = rho_co
    coupled_variables = 'w_co eta_f eta_c eta_g'

    expression = 'h_f*rho_co_f + h_c*rho_co_c + h_g*rho_co_g'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              rho_co_f(w_co) rho_co_c(w_co) rho_co_g(w_co)'
  []

  [x_co]
    type = DerivativeParsedMaterial
    property_name = x_co
    coupled_variables = 'w_co eta_f eta_c eta_g'

    expression = 'Va*(h_f*rho_co_f + h_c*rho_co_c + h_g*rho_co_g)'

    material_property_names = 'Va h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              rho_co_f(w_co) rho_co_c(w_co) rho_co_g(w_co)'

    outputs = exodus
    output_properties = x_co
  []

  #----------------------------------------------------------------------------#
  # Susceptibilities
  [chi_c]
    type = DerivativeParsedMaterial
    property_name = chi_c
    coupled_variables = 'w_c eta_f eta_c eta_g'

    expression = 'h_f*(1/(Va*k_b*To) * exp(-(w_c+Ef_v_f)/(k_b*To)))
                + h_c*(1/(Va*k_b*To) * exp(-(w_c+Ef_v_c)/(k_b*To)))
                + h_g*(1/(Va^2*A_c_g))'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                                k_b Ef_v_f Ef_v_c Va A_c_g To'
  []

  [chi_o]
    type = DerivativeParsedMaterial
    property_name = chi_o
    coupled_variables = 'w_o eta_f eta_c eta_g'

    expression = 'h_f*(1/(Va*k_b*To) * exp((w_o-Ef_o_f)/(k_b*To)))
                + h_c*(1/(Va*k_b*To) * exp((w_o-Ef_o_c)/(k_b*To)))
                + h_g*(1/(Va^2*A_o_g))'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              k_b Ef_o_f Ef_o_c Va A_o_g To'
  []

  [chi_co]
    type = DerivativeParsedMaterial
    property_name = chi_co
    coupled_variables = 'w_co eta_f eta_c eta_g'

    expression = 'h_f*(1/(Va*k_b*To) * exp((w_co-Ef_co_f)/(k_b*To)))
                + h_c*(1/(Va*k_b*To) * exp((w_co-Ef_co_c)/(k_b*To)))
                +h_g*(1/(Va^2*A_co_g))'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)
                              k_b Ef_co_f Ef_co_c Va A_co_g To'
  []

  #----------------------------------------------------------------------------#
  #####     ##    #####     ##    #    #   ####
  #    #   #  #   #    #   #  #   ##  ##  #
  #    #  #    #  #    #  #    #  # ## #   ####
  #####   ######  #####   ######  #    #       #
  #       #    #  #   #   #    #  #    #  #    #
  #       #    #  #    #  #    #  #    #   ####
  #----------------------------------------------------------------------------#
  #----------------------------------------------------------------------------#
  # Reaction rate
  [reactivity_CO]
    type = DerivativeParsedMaterial
    property_name = K_CO
    coupled_variables = 'eta_f eta_c eta_g T'

    expression = 'K_pre/(int_width/2) * exp(-Q/(k_Boltz*T))'

    material_property_names = 'int_width K_pre(eta_f,eta_c,eta_g) Q k_Boltz'
  []

  [K_pre]
    type = DerivativeParsedMaterial
    property_name = K_pre
    coupled_variables = 'eta_f eta_c eta_g'

    expression = 'M_K*eta_c^2*eta_g^2*K_pre_char'

    constant_names = 'M_K'
    constant_expressions = '20.816208'

    material_property_names = 'K_pre_char'
  []

  #----------------------------------------------------------------------------#
  # Reaction rate params
  [K_params]
    type = GenericConstantMaterial

    prop_names  = 'K_pre_char        Q               k_Boltz      K_tol'
    prop_values = '1.3638            5.3772e-01      8.6173e-5    1e-4'
  []

  #----------------------------------------------------------------------------#
  # Interface Width
  [int_width]
    type = GenericConstantMaterial

    prop_names = 'int_width'
    prop_values = '4644' # eta's width
  []

  #----------------------------------------------------------------------------#
  [Ave_K_CO_char] # K_CO using average T in the char
    type = ParsedMaterial
    property_name = Ave_K_CO_char
    coupled_variables = 'T_char_var'

    expression = 'K_pre_char/(int_width/2) * exp(-Q/(k_Boltz*T_char_var))'

    material_property_names = 'int_width K_pre_char Q k_Boltz'
  []

  #----------------------------------------------------------------------------#
  # Phase mobility
  [phase_mobility_char]
    type = DerivativeParsedMaterial
    property_name = L

    expression = '4/3 * 1/int_width * alpha * Ave_K_CO_char'

    constant_names        = 'alpha'
    constant_expressions  = '174150000'

    material_property_names = 'int_width Ave_K_CO_char'
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

  #----------------------------------------------------------------------------#
  # Constant parameters
  [params]
    type = GenericConstantMaterial
    prop_names = 'To     k_b          Va'
    prop_values = '3000   2.2096e-05  1.0'
  []

  [formation_energies_f]
    type = GenericConstantMaterial
    prop_names = 'Ef_v_f    Ef_o_f            Ef_co_f'
    prop_values = '1.0     1.5641e+00        1.6179e+00'
  []

  [formation_energies_c]
    type = GenericConstantMaterial
    prop_names = 'Ef_v_c    Ef_o_c            Ef_co_c'
    prop_values = '1.0     1.5641e+00        1.6179e+00'
  []

  [params_carbon]
    type = GenericConstantMaterial
    prop_names = 'A_c_g        xeq_c_g'
    prop_values = '2e-1           0.0'
  []

  [params_oxygen]
    type = GenericConstantMaterial
    prop_names = 'A_o_g        xeq_o_g'
    prop_values = '1e-6          0.999'
  []

  [params_mono]
    type = GenericConstantMaterial
    prop_names = 'A_co_g       xeq_co_g'
    prop_values = '1e-6           0.0'
  []

  #----------------------------------------------------------------------------#
  # Diffusivities
  [diff_c]
    type = DerivativeParsedMaterial
    property_name = D_c
    coupled_variables = 'eta_f eta_c eta_g'

    expression = 'h_f*1.0 + h_c*1.0 + h_g*9.3458e+11'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)'
  []

  [diff_o]
    type = DerivativeParsedMaterial
    property_name = D_o
    coupled_variables = 'eta_f eta_c eta_g'

    expression = 'h_f*2.8037e+09 + h_c*2.8037e+09 + h_g*9.3458e+11'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)'
  []

  [diff_co]
    type = DerivativeParsedMaterial
    property_name = D_co
    coupled_variables = 'eta_f eta_c eta_g'

    expression = 'h_f*2.8037e+09 + h_c*2.8037e+09 + h_g*9.3458e+11'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)'
  []

  #----------------------------------------------------------------------------#
  # Mobilities
  [mob_c]
    type = DerivativeParsedMaterial
    property_name = Dchi_c
    coupled_variables = 'w_c eta_f eta_c eta_g'

    expression = 'D_c*chi_c'

    material_property_names = 'D_c(eta_f,eta_c,eta_g) chi_c(w_c,eta_f,eta_c,eta_g)'
  []

  [mob_o]
    type = DerivativeParsedMaterial
    property_name = Dchi_o
    coupled_variables = 'w_o eta_f eta_c eta_g'

    expression = 'D_o*chi_o'

    material_property_names = 'D_o(eta_f,eta_c,eta_g) chi_o(w_o,eta_f,eta_c,eta_g)'
  []

  [mob_co]
    type = DerivativeParsedMaterial
    property_name = Dchi_co
    coupled_variables = 'w_co eta_f eta_c eta_g'

    expression = 'D_co*chi_co'

    material_property_names = 'D_co(eta_f,eta_c,eta_g) chi_co(w_co,eta_f,eta_c,eta_g)'
  []

  #----------------------------------------------------------------------------#
  # Heat conduction parameters
  [thcond_f]
    type = VariabletoTensor
    var_xx = var_00
    var_xy = var_01
    var_xz = var_02
    var_yx = var_10
    var_yy = var_11
    var_yz = var_12
    var_zx = var_20
    var_zy = var_21
    var_zz = var_22

    M_name = thcond_f
  []

  [thcond_c]
    type = ConstantAnisotropicMobility
    tensor = '7.4576e+05      0             0
              0               7.4576e+05    0
              0               0             7.4576e+05'

    M_name = thcond_c
  []

  [thcond_g]
    type = ConstantAnisotropicMobility
    tensor = '2.6501e+04      0             0
              0               2.6501e+04    0
              0               0             2.6501e+04'

    M_name = thcond_g
  []

  # Creates a compound tensor for the entire domain
  [thcond_composite]
    type = CompositeMobilityTensor
    coupled_variables = 'eta_f eta_c eta_g'

    weights = 'h_f       h_c        h_g'
    tensors = 'thcond_f  thcond_c   thcond_g'

    M_name = thcond_aniso
  []

  #----------------------------------------------------------------------------#
  # Specific heat
  [cp]
    type = DerivativeParsedMaterial
    property_name = specific_heat
    coupled_variables = 'eta_f eta_c eta_g'

    expression = 'h_f * (4.0010e+09) + h_c * (3.5599e+09) + h_g * (1.9941e+09)'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)'
  []

  #----------------------------------------------------------------------------#
  # Density
  [density]
    type = DerivativeParsedMaterial
    property_name = density
    coupled_variables = 'eta_f eta_c eta_g'

    expression = 'h_f * (1.9944e-14) + h_c * (1.9944e-14) + h_g * (1.2963e-18)'

    material_property_names = 'h_f(eta_f,eta_c,eta_g) h_c(eta_f,eta_c,eta_g) h_g(eta_f,eta_c,eta_g)'
  []

  #------------------------------------------------------------------------------#
  # Conservation check
  [sum_eta]
    type = ParsedMaterial
    property_name = sum_eta
    coupled_variables = 'eta_f eta_c eta_g'

    expression = 'eta_f + eta_c + eta_g'
  []

  [sum_x]
    type = ParsedMaterial
    property_name = sum_x

    expression = 'x_c + x_o + x_co'

    material_property_names = 'x_c x_o x_co'
  []

  [sum_h]
    type = ParsedMaterial
    property_name = sum_h

    expression = 'h_f + h_c + h_g'

    material_property_names = 'h_f h_c h_g'
  []

  [x_V]
    type = ParsedMaterial
    property_name = x_V

    expression = '1 - (x_c + x_o + x_co)'

    material_property_names = 'x_c x_o x_co'

    outputs = exodus
    output_properties = x_V
  []

  #------------------------------------------------------------------------------#
  # Average temperature inside the fiber
  [T_fiber]
    type = ParsedMaterial
    property_name = T_fiber
    coupled_variables = 'T'

    expression = 'h_f * T'

    material_property_names = 'h_f'
  []

  # Average T inside the char
  [T_char]
    type = ParsedMaterial
    property_name = T_char
    coupled_variables = 'T'

    expression = 'h_c * T'

    material_property_names = 'h_c'
  []

[] # End of Materials

#------------------------------------------------------------------------------#
[BCs]
  [oxygen]
    type = DirichletBC
    variable = 'w_o'
    boundary = 'top'
    value = '0'
  []

  [carbon_monoxide]
    type = DirichletBC
    variable = 'w_co'
    boundary = 'top'
    value = '0'
  []

  [heat_flux_top]
    type = NeumannBC
    variable = T
    boundary = 'top'
    # value = '1.2114e-02' # = 1000 W/cm2 divide by gas thermal conductivity
    value = '1.2114e-03' # = 100 W/cm2 divide by gas thermal conductivity
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
  nl_rel_tol = 1.0e-6

  nl_abs_tol = 1e-10

  l_max_its = 60
  l_tol = 1.0e-6

  start_time = 0.0

  dtmin = 1e-6

  # verbose = true

  automatic_scaling = true
  compute_scaling_once = false

  line_search = default
  line_search_package = petsc

  scheme = bdf2

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e3

    growth_factor = 1.2
    cutback_factor = 0.83333

    optimal_iterations = 4 # Number of nonlinear
    linear_iteration_ratio = 30 # Ratio of linear to nonlinear

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
[VectorPostprocessors]
  [grain_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_tracker
    single_feature_per_element = true
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []

  [feature_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = feature_counter
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
    single_feature_per_element = false
  []
[]

#------------------------------------------------------------------------------#
[Postprocessors]
  [grain_tracker]
    type = GrainTracker
    variable = 'eta_f eta_c eta_g'
    threshold = 0.1
    compute_var_to_feature_map = true
    execute_on = 'INITIAL'
    remap_grains = false

    outputs = 'csv'
  []

  # Fiber counter
  [feature_counter]
    type = FeatureFloodCount
    variable = eta_f
    compute_var_to_feature_map = true
    threshold = 0.1

    outputs = 'csv'
  []

  # Mesh Volume
  [volume]
    type = VolumePostprocessor
    execute_on = 'INITIAL'

    outputs = 'csv'
  []

  # Volume of fibers
  [volume_fiber]
    type = FeatureVolumeFraction
    mesh_volume = volume
    feature_volumes = feature_volumes

    outputs = 'csv'
  []

  # Surface area of fibers
  [surface_area_fiber_gas]
    type = GrainBoundaryArea
    v = 'eta_f eta_g'

    grains_per_side = 1

    outputs = 'csv'
  []

  # Surface area of char
  [surface_area_char_gas]
    type = GrainBoundaryArea
    v = 'eta_c eta_g'

    grains_per_side = 1

    outputs = 'csv'
  []

  # Surface area of fibers
  [surface_area_fiber_char]
    type = GrainBoundaryArea
    v = 'eta_f eta_c'

    grains_per_side = 2

    outputs = 'csv'
  []

  # Integral temperature inside the fiber = h_f * T
  [T_fiber_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'T_fiber'
    execute_on = 'INITIAL TIMESTEP_END'

    outputs = 'csv'
  []

  # Average temperature inside the fiber
  [Ave_T_fiber]
    type = FunctionValuePostprocessor
    function = 'T_fiber_func'

    outputs = 'csv'
  []

  # Integral temperature inside the char = h_c * T
  [T_char_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'T_char'
    execute_on = 'INITIAL TIMESTEP_END'

    outputs = 'csv'
  []

  # Average temperature inside the char
  [Ave_T_char]
    type = FunctionValuePostprocessor
    function = 'T_char_func'

    outputs = 'csv'
  []

  # Average temperature in the whole domain
  [Ave_T_domain]
    type = AverageNodalVariableValue
    variable = T

    outputs = 'csv'
  []

  # Area integrals
  [int_eta_f]
    type = ElementIntegralVariablePostprocessor
    variable = eta_f

    outputs = 'csv'
  []

  [int_eta_c]
    type = ElementIntegralVariablePostprocessor
    variable = eta_c

    outputs = 'csv'
  []

  [int_eta_g]
    type = ElementIntegralVariablePostprocessor
    variable = eta_g

    outputs = 'csv'
  []

  # Species output
  [int_h_f]
    type = ElementIntegralMaterialProperty
    mat_prop = h_f
    execute_on = 'INITIAL TIMESTEP_END'

    outputs = 'csv exodus console'
  []

  [int_h_c]
    type = ElementIntegralMaterialProperty
    mat_prop = h_c
    execute_on = 'INITIAL TIMESTEP_END'

    outputs = 'csv exodus console'
  []

  [int_h_g]
    type = ElementIntegralMaterialProperty
    mat_prop = h_g
    execute_on = 'INITIAL TIMESTEP_END'

    outputs = 'csv exodus console'
  []

  # Species output
  [total_carbon]
    type = ElementIntegralMaterialProperty
    mat_prop = x_c

    outputs = 'csv exodus'
  []

  [total_oxygen]
    type = ElementIntegralMaterialProperty
    mat_prop = x_o

    outputs = 'csv exodus'
  []

  [total_mono]
    type = ElementIntegralMaterialProperty
    mat_prop = x_co

    outputs = 'csv exodus'
  []

  [omega_chem]
    type = ElementIntegralMaterialProperty
    mat_prop = omega

    outputs = 'csv'
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
  file_base = ./results/step2_char_out

  # checkpoint = true

  [console]
    type = Console
    fit_mode = 80
    max_rows = 10
  []

  [exodus]
    type = Exodus
    execute_on = 'INITIAL TIMESTEP_END'
    time_step_interval = 20
  []

  [csv]
    type = CSV
    execute_on = 'INITIAL TIMESTEP_END'
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
