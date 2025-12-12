#------------------------------------------------------------------------------#
# Carbon Fiber Oxidation
# Nondimensional parameters with convertion factors:
lo = 2.3973586e-03 #2.1524e-05  # micron 
to = 4.3299e-04 # s 
eo = 3.9 # eV
Av = 6.02214076e23 # avogadro's number
ev = 6.242e18 #conversion from J to EV								  
# This file reads the IC of the fibers and gas order parameters from step1,
# as well as the anisotropic thermal conductivity tensor. In this final step,
# we perform the phase-field carbon fiber oxidation fully coupled with heat
# conduction.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# [Mesh]
#   # Create a mesh representing the EBSD data
#   [ebsd_mesh]
#     type = EBSDMeshGenerator
#     filename = SimpleBoxTest_EBSD.txt
#     pre_refine = 0
#   []
#     parallel_type = DISTRIBUTED
# []

[Mesh]
  [gen]
    type = DistributedRectilinearMeshGenerator
    dim = 2

    xmin = 0
    xmax = 11429 # 120 microns
    nx = 16

    ymin = 100000
    ymax = 138773 # 120 microns
    ny = 52

    elem_type = QUAD4
  []

  uniform_refine = 0
[]

#------------------------------------------------------------------------------#
[GlobalParams]
  # Interface thickness for the Grand Potential material
  width = 4644 #${fparse 1/lo} # 24247 #48494 # int_width 5 micron, half of the total width

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
    mesh = SimpleBoxTest_step1_exodus.e
    system_variables = 'eta_f eta_g
                        var_00 var_01 var_02
                        var_10 var_11 var_12
                        var_20 var_21 var_22'
    timestep = 'LATEST'
  []

  [detect_fiber]
    type = Terminator
    expression = 'int_h_f < 1e6'
  []
  # [ebsd]
  #   # Read in the EBSD data. Uses the filename given in the mesh block.
  #   type = EBSDReader
  # []
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
    expression = '(T_top - T_bottom)/l_domain * y + T_bottom'

    symbol_names = 'T_bottom  T_top   l_domain'
    symbol_values = '1988      2000    139455' #${fparse 30/lo}' #1551853' # 12 K over 120 microns
  []

  [T_fiber_func]
    type = ParsedFunction
    expression = 'T_fiber_pp / (int_h_f)'
    symbol_names = 'T_fiber_pp int_h_f'
    symbol_values = 'T_fiber_pp int_h_f'
  []
    [ic_func_eta_f]
    type = SolutionFunction
    from_variable = eta_f
    solution = solution_uo
  []
  [ic_func_eta_g]
    type = SolutionFunction
    from_variable = eta_g
    solution = solution_uo
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
  [IC_eta_f]
    type = FunctionIC
    variable = eta_f
    function = ic_func_eta_f
  []
  [IC_eta_g]
    type = FunctionIC
    variable = eta_g
    function = ic_func_eta_g
  []

  [IC_w_c]
    type = ConstantIC
    variable = w_c
    value = 0
  []
  [IC_w_o]
    type = ConstantIC
    variable = w_o
    value = 0
  []
  [IC_w_co]
    type = ConstantIC
    variable = w_co
    value = 0
  []

  [IC_T]
    type = FunctionIC
    variable = T
    function = ic_func_T
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
  [total_energy]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  []
  [omega_inter]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  []

  [T_fiber_var]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 2000
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

  [flux_c_x]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [flux_c_y]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []

  [flux_o_x]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [flux_o_y]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []

  [flux_co_x]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
  [flux_co_y]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.0
  []
[]

#------------------------------------------------------------------------------#
[AuxKernels]
  # Total energy in the system for visualization purposes
  [total_energy]
    type = TotalFreeEnergy
    variable = total_energy
    f_name = omega
    additional_free_energy = omega_inter
    interfacial_vars  = 'eta_f eta_g'
    kappa_names       = 'kappa kappa'
  []

  # Interfacial grand potential for visualization purposes
  [aux_omega_inter]
    type = MaterialRealAux
    property = omega_inter
    variable = omega_inter
  []

  # Average T in the fibers
  [aux_T_fiber]
    type = FunctionAux
    function = T_fiber_func
    variable = T_fiber_var
  []

  # Diffusion flux of each species for visualization purposes
  [aux_flux_c_x]
    type = DiffusionFluxAux
    variable = flux_c_x
    diffusion_variable = w_c
    diffusivity = Dchi_c
    component = x
  []
  [aux_flux_c_y]
    type = DiffusionFluxAux
    variable = flux_c_y
    diffusion_variable = w_c
    diffusivity = Dchi_c
    component = y
  []

  [aux_flux_o_x]
    type = DiffusionFluxAux
    variable = flux_o_x
    diffusion_variable = w_o
    diffusivity = Dchi_o
    component = x
  []
  [aux_flux_o_y]
    type = DiffusionFluxAux
    variable = flux_o_y
    diffusion_variable = w_o
    diffusivity = Dchi_o
    component = y
  []

  [aux_flux_co_x]
    type = DiffusionFluxAux
    variable = flux_co_x
    diffusion_variable = w_co
    diffusivity = Dchi_co
    component = x
  []
  [aux_flux_co_y]
    type = DiffusionFluxAux
    variable = flux_co_y
    diffusion_variable = w_co
    diffusivity = Dchi_co
    component = y
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
    coupled_variables = 'w_o eta_f eta_g T'
  []

  [reaction_kernel_O]
    type = MaskedBodyForce
    variable = w_o
    mask = reaction_CO
    coupled_variables = 'w_c eta_f eta_g T'
  []

  [reaction_kernel_CO]
    type = MaskedBodyForce
    variable = w_co
    mask = production_CO
    coupled_variables = 'w_c w_o eta_f eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Endothermic Reaction
  [reaction_energy_CO]
    type = MaskedBodyForce
    variable = T
    mask = energy_CO
    coupled_variables = 'w_c w_o eta_f eta_g'
  []
  #----------------------------------------------------------------------------#
  # eta_f kernels
  [AC_f_bulk]
    type = ACGrGrMulti
    variable = eta_f
    v = 'eta_g'
    gamma_names = 'gamma_fg'
    mob_name = L
    # coupled_variables = 'T_fiber_var'
  []

  [AC_f_sw]
    type = ACSwitching
    variable = eta_f
    Fj_names = 'omega_f omega_g'
    hj_names = 'h_f     h_g'
    mob_name = L
    coupled_variables = 'w_c w_o w_co eta_g T'
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
    # coupled_variables = 'T_fiber_var'
  []

  [AC_g_sw]
    type = ACSwitching
    variable = eta_g
    Fj_names = 'omega_f omega_g'
    hj_names = 'h_f     h_g'
    mob_name = L
    coupled_variables = 'w_c w_o w_co eta_f T'
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
  # Chemical potential kernels
  #----------------------------------------------------------------------------#
  # Carbon
  [w_c_dot]
    type = SusceptibilityTimeDerivative
    variable = w_c
    f_name = chi_c
    coupled_variables = 'w_c eta_f eta_g T'
  []

  [diffusion_c]
    type = MatDiffusion
    variable = w_c
    diffusivity = Dchi_c
    args = 'w_c eta_f eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Oxygen
  [w_o_dot]
    type = SusceptibilityTimeDerivative
    variable = w_o
    f_name = chi_o
    coupled_variables = 'w_o eta_f eta_g T'
  []

  [diffusion_o]
    type = MatDiffusion
    variable = w_o
    diffusivity = Dchi_o
    args = 'w_o eta_f eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Carbon Monoxide
  [w_co_dot]
    type = SusceptibilityTimeDerivative
    variable = w_co
    f_name = chi_co
    coupled_variables = 'w_co eta_f eta_g T'
  []

  [diffusion_co]
    type = MatDiffusion
    variable = w_co
    diffusivity = Dchi_co
    args = 'w_co eta_f eta_g T'
  []

  #----------------------------------------------------------------------------#
  # Coupled kernels
  #----------------------------------------------------------------------------#
  # Carbon
  [coupled_eta_f_dot_c]
    type = CoupledSwitchingTimeDerivative
    variable = w_c
    v = eta_f
    Fj_names = 'rho_c_f  rho_c_g'
    hj_names = 'h_f      h_g'
    coupled_variables = 'eta_f eta_g w_o w_co T'
  []

  [coupled_eta_g_dot_c]
    type = CoupledSwitchingTimeDerivative
    variable = w_c
    v = eta_g
    Fj_names = 'rho_c_f  rho_c_g'
    hj_names = 'h_f      h_g'
    coupled_variables = 'eta_f eta_g w_o w_co T'
  []

  #----------------------------------------------------------------------------#
  # Oxygen
  [coupled_eta_f_dot_o]
    type = CoupledSwitchingTimeDerivative
    variable = w_o
    v = eta_f
    Fj_names = 'rho_o_f  rho_o_g'
    hj_names = 'h_f      h_g'
    coupled_variables = 'eta_f eta_g w_c w_co T'
  []

  [coupled_eta_g_dot_o]
    type = CoupledSwitchingTimeDerivative
    variable = w_o
    v = eta_g
    Fj_names = 'rho_o_f  rho_o_g'
    hj_names = 'h_f      h_g'
    coupled_variables = 'eta_f eta_g w_c w_co T'
  []

  #----------------------------------------------------------------------------#
  # Carbon Monoxide
  [coupled_eta_f_dot_co]
    type = CoupledSwitchingTimeDerivative
    variable = w_co
    v = eta_f
    Fj_names = 'rho_co_f rho_co_g'
    hj_names = 'h_f      h_g'
    coupled_variables = 'eta_f eta_g w_c w_o T'
  []

  [coupled_eta_g_dot_co]
    type = CoupledSwitchingTimeDerivative
    variable = w_co
    v = eta_g
    Fj_names = 'rho_co_f rho_co_g'
    hj_names = 'h_f      h_g'
    coupled_variables = 'eta_f eta_g w_c w_o T'
  []

  #----------------------------------------------------------------------------#
  # Heat Conduction kernels
  [Heat_Conduction]
    type = MatAnisoDiffusion
    variable = T
    args = 'eta_f eta_g'

    diffusivity = thcond_aniso
  []

  # Transient heat conduction kernel example
  # Provide cp and density as material properties
  # [Heat_Time_Derivative]
  #   type = SpecificHeatConductionTimeDerivative
  #   variable = T
  #   args = 'eta_f eta_g'
  #
  #   density = density
  #   specific_heat = specific_heat
  # []
  [Heat_Time_Derivative]
    type = SpecificHeatConductionTimeDerivative
    variable = T
    coupled_variables = 'eta_f eta_g'

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
    coupled_variables = 'w_c w_o eta_f eta_g T'

    expression= 'if(rho_c>K_tol&rho_o>K_tol,K_CO*rho_c*rho_o,0)'

    material_property_names = 'K_CO(T) rho_c(w_c,eta_f,eta_g) rho_o(w_o,eta_f,eta_g) K_tol'
    outputs = exodus
  []

  [CO_reaction_consumption]
    type = DerivativeParsedMaterial
    property_name = reaction_CO
    coupled_variables = 'w_c w_o eta_f eta_g T'

    expression= 'if(rho_c>K_tol&rho_o>K_tol,-K_CO*rho_c*rho_o,0)'

    material_property_names = 'K_CO(T) rho_c(w_c,eta_f,eta_g) rho_o(w_o,eta_f,eta_g) K_tol'
  []

  #----------------------------------------------------------------------------#
  # Reaction Energy
  [CO_reaction_energy] # Endothermic
    type = DerivativeParsedMaterial
    property_name = energy_CO
    coupled_variables = 'w_c w_o eta_f eta_g T'

    expression= 'if(rho_c>K_tol&rho_o>K_tol,-dH*K_CO*rho_c*rho_o,0)'

    constant_names = 'dH'

    constant_expressions = ${fparse 100*1000*ev/(Av*eo)} # = 100 kJ/mol

    material_property_names = 'K_CO(T) rho_c(w_c,eta_f,eta_g) rho_o(w_o,eta_f,eta_g) K_tol'
  []

  #----------------------------------------------------------------------------#
  [concentration_C]
    type = DerivativeParsedMaterial
    property_name = concentration_C
    coupled_variables = 'w_c w_o eta_f eta_g T'

    expression= 'if(rho_c>K_tol&rho_o>K_tol,rho_c,0)'

    material_property_names = 'K_CO(T) rho_c(w_c,eta_f,eta_g) rho_o(w_o,eta_f,eta_g) K_tol'
    outputs = exodus
  []
  [concentration_O]
    type = DerivativeParsedMaterial
    property_name = concentration_O
    coupled_variables = 'w_c w_o eta_f eta_g T'

    expression= 'if(rho_c>K_tol&rho_o>K_tol,rho_o,0)'

    material_property_names = 'K_CO(T) rho_c(w_c,eta_f,eta_g) rho_o(w_o,eta_f,eta_g) K_tol'
    outputs = exodus
  []
  #----------------------------------------------------------------------------#
  # Switching functions
  [switch_f]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_f
    all_etas = 'eta_f eta_g'
    phase_etas = 'eta_f'
  []

  [switch_g]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h_g
    all_etas = 'eta_f eta_g'
    phase_etas = 'eta_g'
  []

  #----------------------------------------------------------------------------#
  # Grand potential densities
  # Fibers: Dilute solution model
  [omega_f]
    type = DerivativeParsedMaterial
    property_name = omega_f
    coupled_variables = 'w_c w_o w_co'

    expression= '-w_c/Va -k_b*To/Va * exp(-(w_c+Ef_v)/(k_b*To))
                -k_b*To/Va * exp((w_o-Ef_o_f)/(k_b*To))
                -k_b*To/Va * exp((w_co-Ef_co_f)/(k_b*To))'

    material_property_names = 'To k_b Va Ef_o_f Ef_co_f Ef_v'
  []

  # Gas phase: Parabolic
  [omega_g]
    type = DerivativeParsedMaterial
    property_name = omega_g
    coupled_variables = 'w_c w_o w_co'

    expression= '-1/2*w_c^2/(Va^2*A_c_g) -w_c*xeq_c_g/Va
                -1/2*w_o^2/(Va^2*A_o_g) -w_o*xeq_o_g/Va
                -1/2*w_co^2/(Va^2*A_co_g) -w_co*xeq_co_g/Va'

    material_property_names = 'Va A_o_g A_c_g A_co_g xeq_o_g xeq_c_g xeq_co_g'
  []

  [omega]
    type = DerivativeParsedMaterial
    property_name = omega
    coupled_variables = 'w_c w_o w_co eta_f eta_g'

    expression= 'h_f*omega_f + h_g*omega_g'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) omega_f(w_c,w_o,w_co)
                              omega_g(w_c,w_o,w_co)'
  []

  [out_omega_f]
    type = ParsedMaterial
    property_name = out_omega_f

    expression= 'h_f*omega'

    material_property_names = 'h_f omega'
  []

  [out_omega_g]
    type = ParsedMaterial
    property_name = out_omega_g

    expression= 'h_g*omega'

    material_property_names = 'h_g omega'
  []

  #----------------------------------------------------------------------------#
  # Grand potential density interfacial part for visualization purposes
  [omega_inter]
    type = ParsedMaterial
    property_name = omega_inter
    coupled_variables = 'eta_f eta_g'

    expression=  'mu * ((eta_f^4)/4 - (eta_f^2)/2 + (eta_g^4)/4 - (eta_g^2)/2
                + gamma/2 * (eta_f^2)*(eta_g^2) + gamma/2 * (eta_f^2)*(eta_g^2) + 1/4)'

    constant_names        = 'gamma'
    constant_expressions  = '1.5'

    material_property_names = 'mu'
  []

  #----------------------------------------------------------------------------#
  # CARBON
  [rho_c_f]
    type = DerivativeParsedMaterial
    property_name = rho_c_f
    coupled_variables = 'w_c'

    expression= '1/Va*(1 - exp(-(w_c+Ef_v)/(k_b*To)))'

    material_property_names = 'To Va Ef_v k_b'
  []

  [rho_c_g]
    type = DerivativeParsedMaterial
    property_name = rho_c_g
    coupled_variables = 'w_c'

    expression= '1/Va*(w_c/(Va*A_c_g) + xeq_c_g)'

    material_property_names = 'Va A_c_g xeq_c_g'
  []

  [rho_c]
    type = DerivativeParsedMaterial
    property_name = rho_c
    coupled_variables = 'w_c eta_f eta_g'

    expression= '(h_f*rho_c_f + h_g*rho_c_g)/8.76'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_c_f(w_c) rho_c_g(w_c)'
    outputs = exodus
  []

  [x_c]
    type = DerivativeParsedMaterial
    property_name = x_c
    coupled_variables = 'w_c eta_f eta_g'

    expression= 'Va*(h_f*rho_c_f + h_g*rho_c_g)/8.76'

    material_property_names = 'Va h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_c_f(w_c) rho_c_g(w_c)'

    outputs = exodus
    output_properties = x_c
  []

  [c_fiber_out]
    type = ParsedMaterial
    property_name = x_c_out

    expression= 'h_f*x_c'

    material_property_names = 'h_f x_c'
  []

  #----------------------------------------------------------------------------#
  # OXYGEN
  [rho_o_f]
    type = DerivativeParsedMaterial
    property_name = rho_o_f
    coupled_variables = 'w_o'

    expression= '1/Va * exp((w_o-Ef_o_f)/(k_b*To))'

    material_property_names = 'To Va Ef_o_f k_b'
  []

  [rho_o_g]
    type = DerivativeParsedMaterial
    property_name = rho_o_g
    coupled_variables = 'w_o'

    expression= '1/Va*(w_o/(Va*A_o_g) + xeq_o_g)'

    material_property_names = 'Va A_o_g xeq_o_g'
  []

  [rho_o]
    type = DerivativeParsedMaterial
    property_name = rho_o
    coupled_variables = 'w_o eta_f eta_g'

    expression= 'h_f*rho_o_f + h_g*rho_o_g'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_o_f(w_o) rho_o_g(w_o)'
  []

  [x_o]
    type = DerivativeParsedMaterial
    property_name = x_o
    coupled_variables = 'w_o eta_f eta_g'

    expression= 'Va*(h_f*rho_o_f + h_g*rho_o_g)'

    material_property_names = 'Va h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_o_f(w_o) rho_o_g(w_o)'

    outputs = exodus
    output_properties = x_o
  []

  [o_gas_out]
    type = ParsedMaterial
    property_name = x_o_out

    expression= 'h_g*x_o'

    material_property_names = 'h_g x_o'
  []

  #----------------------------------------------------------------------------#
  # CARBON MONOXIDE
  [rho_co_f]
    type = DerivativeParsedMaterial
    property_name = rho_co_f
    coupled_variables = 'w_co'

    expression= '1/Va * exp((w_co-Ef_co_f)/(k_b*To))'

    material_property_names = 'To Va Ef_co_f k_b'
  []

  [rho_co_g]
    type = DerivativeParsedMaterial
    property_name = rho_co_g
    coupled_variables = 'w_co'

    expression= '1/Va*(w_co/(Va*A_co_g) + xeq_co_g)'

    material_property_names = 'Va A_co_g xeq_co_g'
  []

  [rho_co]
    type = DerivativeParsedMaterial
    property_name = rho_co
    coupled_variables = 'w_co eta_f eta_g'

    expression= 'h_f*rho_co_f + h_g*rho_co_g'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_co_f(w_co) rho_co_g(w_co)'
  []

  [x_co]
    type = DerivativeParsedMaterial
    property_name = x_co
    coupled_variables = 'w_co eta_f eta_g'

    expression= 'Va*(h_f*rho_co_f + h_g*rho_co_g)'

    material_property_names = 'Va h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_co_f(w_co) rho_co_g(w_co)'

    outputs = exodus
    output_properties = x_co
  []

  [co_gas_out]
    type = ParsedMaterial
    property_name = x_co_out

    expression= 'h_g*x_co'

    material_property_names = 'h_g x_co'
  []

  #----------------------------------------------------------------------------#
  # Susceptibilities
  [chi_c]
    type = DerivativeParsedMaterial
    property_name = chi_c
    coupled_variables = 'w_c eta_f eta_g'

    expression= 'h_f*(1/(Va*k_b*To) * exp(-(w_c+Ef_v)/(k_b*To)))
                +h_g*(1/(Va^2*A_c_g))'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) k_b Ef_v Va A_c_g To'
  []

  [chi_o]
    type = DerivativeParsedMaterial
    property_name = chi_o
    coupled_variables = 'w_o eta_f eta_g'

    expression= 'h_f*(1/(Va*k_b*To) * exp((w_o-Ef_o_f)/(k_b*To)))
                +h_g*(1/(Va^2*A_o_g))'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) k_b Ef_o_f Va A_o_g To'
  []

  [chi_co]
    type = DerivativeParsedMaterial
    property_name = chi_co
    coupled_variables = 'w_co eta_f eta_g'

    expression= 'h_f*(1/(Va*k_b*To) * exp((w_co-Ef_co_f)/(k_b*To)))
                +h_g*(1/(Va^2*A_co_g))'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) k_b Ef_co_f Va A_co_g To'
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
  # # Reaction rate
  # [reactivity_CO]
  #   type = DerivativeParsedMaterial
  #   property_name = K_CO
  #   coupled_variables = 'T'

  #   expression = '4.636568011043739e-7'
  #   # expression = '(-2.67571265e-17*T^4 + 1.84215649e-13*T^3 + -4.60758057e-10*T^2 + 4.90363538e-07*T + -1.74420786e-04)* ${fparse ((1e6)^3 * to/(Av*lo^3))}'

  #   # expression= '(-2.39219507e-33*T^9 + 4.95623159e-29*T^8 + -4.42483623e-25*T^7 + 2.22714402e-21*T^6 + 
  #   # -6.93724807e-18*T^5 + 1.37965916e-14*T^4 + -1.73967001e-11*T^3 + 1.32813033e-08*T^2 + -5.49566520e-06*T + 9.32733172e-04)
  #   # * ${fparse ((1e6)^3 * to/(Av*lo^3))}'
  # []


  # Reaction rate
  [reactivity_CO]
    type = DerivativeParsedMaterial
    property_name = K_CO
    coupled_variables = 'T'
    # expression= 'K_pre/(int_width/2) * exp(-Q/(k_Boltz*T))' #Fast reaction original
    # expression = '4.63656e-7'
    expression= 1.8169375279464e-11

    # expression= = 4.63656e-7
    
    
    
    # material_property_names = 'int_width K_pre Q k_Boltz'
  []

  #----------------------------------------------------------------------------#
  # Reaction rate params
  [K_params]
    type = GenericConstantMaterial


    # prop_names  = 'K_pre                             Q               k_Boltz      K_tol'     
    # prop_values = '${fparse 9.46e15*to/(Av*lo^3)}    5.3772e-01      8.6173e-5    1e-4' #${fparse 1.3869e12*to/(Av*lo^3)}'#1e-4'   #Original values 

    prop_names  = 'K_pre                                            Q                                k_Boltz      K_tol'
    # prop_values = '${fparse 8.08489251e-07 *(1e6)^3*to/(Av*lo^3)}   ${fparse -1.75530415e-01 *ev/Av}  8.6173e-5    1e-4'    #Fast reaction values
    prop_values = '4.2189289398916e-08   -1.136752e-24  8.6173e-5    1e-4'    #Fast reaction values #Fast reaction values calculated
    
    
    #${fparse 1.3869e12*to/(Av*lo^3)}'#1e-4'   # ${fparse 9.46e15*to/(Av*lo^3)}    5.3772e-01  
  []
  # [Ave_K_CO] # K_CO using average T in the fiber
  #   type = ParsedMaterial
  #   property_name = Ave_K_CO
  #   coupled_variables = 'T_fiber_var'
  #   # expression= 'K_pre/(int_width/2) * exp(-Q/(k_Boltz*T_fiber_var))' #Fast reaction original
  #   expression= 'K_pre/(int_width/2) * exp(-Q/(k_Boltz*2000))'

  #   material_property_names = 'int_width K_pre Q k_Boltz'
  # []
  #----------------------------------------------------------------------------#
  # Interface Width
  [int_width]
    type = GenericConstantMaterial

    prop_names = 'int_width'
    prop_values = 4644 #'${fparse 1/lo}'#s4644' #'24247' # eta's width
  []

  #----------------------------------------------------------------------------#
  # Fast reaction avg. Not needed while testing const temp variable
  # [Ave_K_CO] # K_CO using average T in the fiber
  #   type = ParsedMaterial
  #   property_name = Ave_K_CO
  #   coupled_variables = 'T_fiber_var'
  #   # expression= 'K_pre/(int_width/2) * exp(-Q/(k_Boltz*T_fiber_var))' #Fast reaction original
  #   expression= 'K_pre/(int_width/2) * exp(-Q/(k_Boltz*2000))'

  #   material_property_names = 'int_width K_pre Q k_Boltz'
  # []


  # Proper ACA reactions
  # [Ave_K_CO] # K_CO using average T in the fiber
  #   type = ParsedMaterial
  #   property_name = Ave_K_CO
  #   coupled_variables = 'T_fiber_var'

  #   expression= '(-2.3921e-33*T_fiber_var^9 + 4.9562e-29*T_fiber_var^8 + -4.4248e-25*T_fiber_var^7 + 2.2271e-21*T_fiber_var^6 + 
  #   -6.9372e-18*T_fiber_var^5 + 1.3796e-14*T_fiber_var^4 + -1.7396e-11*T_fiber_var^3 + 1.3281e-08*T_fiber_var^2 + -5.4956e-06*T_fiber_var + 9.3273e-04)
  #   * ${fparse ((1e6)^3 * to/(Av*lo^3))}'
  # []

  # [Ave_K_CO]
  #   type = DerivativeParsedMaterial
  #   property_name = Ave_K_CO

  #   # expression = '(-2.67571265e-17*2000^4 + 1.84215649e-13*2000^3 + -4.60758057e-10*2000^2 + 4.90363538e-07*2000 + -1.74420786e-04)* ${fparse ((1e6)^3 * to/(Av*lo^3))}'

  #   expression= '(-2.39219507e-33*2000^9 + 4.95623159e-29*2000^8 + -4.42483623e-25*2000^7 + 2.22714402e-21*2000^6 + 
  #   -6.93724807e-18*2000^5 + 1.37965916e-14*2000^4 + -1.73967001e-11*2000^3 + 1.32813033e-08*2000^2 + -5.49566520e-06*2000 + 9.32733172e-04)
  #   * ${fparse ((1e6)^3 * to/(Av*lo^3))}'
  # []
  #----------------------------------------------------------------------------#
  # # Phase mobility
  [phase_mobility]
    type = DerivativeParsedMaterial
    property_name = L
    # expression = '1e-2'
    # expression= '4/3 * 1/int_width * alpha * K_CO'

    # expression = 0.031221


    expression = 1.2234776417570828626205511860250129198e-6
    
    
    # constant_names        = 'alpha'
    # constant_expressions  = '${fparse 9.6114e3*eo*(15)/(lo)}'   # s143c4b02.1524e-0500'  ((lo/(2.1524e-04))^3)
    # constant_expressions  = 2.3453600141422313708095234480148e8

    # material_property_names = 'int_width K_CO'
    outputs = exodus
  []

  #----------------------------------------------------------------------------#
  # Grand Potential Interface Parameters
  [iface]
    type = GrandPotentialInterface
    gamma_names = 'gamma_fg'

    sigma = '${fparse 0.2*ev/(1e6)^2*(lo^2)/eo}'  # = 0.2 J/m2

    kappa_name = kappa
    mu_name = mu

    sigma_index = 0
  []

  #----------------------------------------------------------------------------#
  # Constant parameters
  [params]
    type = GenericConstantMaterial
    prop_names = 'To     k_b        			 Va'
    prop_values = '3000  ${fparse 8.6173e-5/eo}  ${fparse 9.97e-12/lo^3}'
  []

  [formation_energies]
    type = GenericConstantMaterial
    prop_names = 'Ef_v                Ef_o_f            Ef_co_f'
    prop_values = '${fparse 3.9/eo}  ${fparse 6.10/eo}  ${fparse 6.31/eo}'
  []

  [params_carbon]
    type = GenericConstantMaterial
    prop_names = 'A_c_g                             xeq_c_g'
    prop_values = '${fparse 7.82e1/(1e-9)*lo^3/eo}  0.0'    
  []

  [params_oxygen]
    type = GenericConstantMaterial
    prop_names = 'A_o_g                               xeq_o_g'
    prop_values = '${fparse 3.91e-4/(1e-9)*lo^3/eo}   0.999' #0' #  
  []
  [params_mono]
    type = GenericConstantMaterial
    prop_names = 'A_co_g      							 xeq_co_g'
    prop_values = '${fparse 3.91e-4/(1e-9)*lo^3/eo}    0.0'
  []

  #----------------------------------------------------------------------------#
  # Diffusivities
  [diff_c]
    type = DerivativeParsedMaterial
    property_name = D_c
    coupled_variables = 'eta_f eta_g'

    # expression= '(h_f*${fparse 1.07e-12*1e8*to/lo^2})*1e11 + (h_g*${fparse 1*1e8*to/lo^2})'
    # expression= '(h_f*${fparse 1.07e-12*1e8*to/lo^2} + h_g*${fparse 1*1e8*to/lo^2})*1e9'
    expression= '(h_f*${fparse 1.07e-12*1e8*to/lo^2} + h_g*${fparse 1*1e8*to/lo^2})'
    
    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  [diff_o]
    type = DerivativeParsedMaterial
    property_name = D_o
    coupled_variables = 'eta_f eta_g'

    # expression= '(h_f*${fparse 3e-3*1e8*to/lo^2} + h_g*${fparse 1*1e8*to/lo^2})*1e9'
    expression= '(h_f*${fparse 3e-3*1e8*to/lo^2} + h_g*${fparse 1*1e8*to/lo^2})'
    
    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  [diff_co]
    type = DerivativeParsedMaterial
    property_name = D_co
    coupled_variables = 'eta_f eta_g'

    # expression= '(h_f*${fparse 3e-3*1e8*to/lo^2} + h_g*${fparse 1*1e8*to/lo^2})*1e9' 
    expression= '(h_f*${fparse 3e-3*1e8*to/lo^2} + h_g*${fparse 1*1e8*to/lo^2})' 

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  #----------------------------------------------------------------------------#
  # Mobilities
  [mob_c]
    type = DerivativeParsedMaterial
    property_name = Dchi_c
    coupled_variables = 'w_c eta_f eta_g'

    expression= 'D_c*chi_c'

    material_property_names = 'D_c(eta_f,eta_g) chi_c(w_c,eta_f,eta_g)'
  []

  [mob_o]
    type = DerivativeParsedMaterial
    property_name = Dchi_o
    coupled_variables = 'w_o eta_f eta_g'

    expression= 'D_o*chi_o'

    material_property_names = 'D_o(eta_f,eta_g) chi_o(w_o,eta_f,eta_g)'
  []

  [mob_co]
    type = DerivativeParsedMaterial
    property_name = Dchi_co
    coupled_variables = 'w_co eta_f eta_g'

    expression= 'D_co*chi_co'

    material_property_names = 'D_co(eta_f,eta_g) chi_co(w_co,eta_f,eta_g)'
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
  # [thcond_f]
  #   type = ConstantAnisotropicMobility
  #   tensor = '${fparse 50*lo*ev*to/(1e6*eo)}    0                                   0
  #             0                                 ${fparse 0.5*lo*ev*to/(1e6*eo)}     0
  #             0                                 0                                   ${fparse 0.5*lo*ev*to/(1e6*eo)}'
  #   M_name = thcond_f  
  # []
  [thcond_g]
    type = ConstantAnisotropicMobility
    tensor = '${fparse 0.18*lo*ev*to/(1e6*eo)}        0                                     0
              0                                       ${fparse 0.18*lo*ev*to/(1e6*eo)}      0
              0                                       0                                     ${fparse 0.18*lo*ev*to/(1e6*eo)} '

    # tensor = '2.6501e+04      0             0
    #           0               2.6501e+04    0
    #           0               0             2.6501e+04'

    M_name = thcond_g
  []

  # Creates a compound tensor for the entire domain
  [thcond_composite]
    type = CompositeMobilityTensor
    coupled_variables = 'eta_f eta_g'

    weights = 'h_f       h_g'
    tensors = 'thcond_f  thcond_g'

    M_name = thcond_aniso
  []
  #----------------------------------------------------------------------------#
  # Specific heat
  [cp]
    type = DerivativeParsedMaterial
    property_name = specific_heat
    coupled_variables = 'eta_f eta_g'

    expression = 'h_f *${fparse 2.5*ev/eo} + h_g * ${fparse 1.25*ev/eo}'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []

  #----------------------------------------------------------------------------#
  # Density
  [density]
    type = DerivativeParsedMaterial
    property_name = density
    coupled_variables = 'eta_f eta_g'

    expression = 'h_f * ${fparse (2/1e12)*lo^3} + h_g * ${fparse (1.3e-4/1e12)*lo^3}'

    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g)'
  []
  #------------------------------------------------------------------------------#
  # Surface Area
  [Surface_Area]
    type = ParsedMaterial
    property_name = Surface_Area
    coupled_variables = 'eta_f eta_g'
    expression = 'eta_f^2 * eta_g^2 * 16'
    outputs = 'exodus'
  []
  [Surface_Concentration_C] 
    type = ParsedMaterial
    property_name = Surface_Concentration_C
    coupled_variables = 'eta_f eta_g w_c'
    expression = '(h_f*rho_c_f + h_g*rho_c_g)/8.76*(eta_f^2 * eta_g^2 * 20.816208)* 1/11429 *1/(int_width*2)*  ${fparse 1/Av *(1e6/lo)^2}'  #1/(int_width*2)*   #${fparse (1e6/lo)^3 * 1/Av*1/(lo*1e-6)}  (int_width*2) * 
    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_c_f(w_c) rho_c_g(w_c) int_width'
    outputs = 'exodus'
  []
    [Surface_Concentration_o] 
    type = ParsedMaterial
    property_name = Surface_Concentration_o
    coupled_variables = 'eta_f eta_g w_o'
    expression = '(h_f*rho_o_f + h_g*rho_o_g)*(eta_f^2 * eta_g^2 * 20.816208)* 1/11429 *1/(int_width*2)*  ${fparse 1/Av *(1e6/lo)^2}'  #1/(int_width*2)*   #${fparse (1e6/lo)^3 * 1/Av*1/(lo*1e-6)}  (int_width*2) * 
    material_property_names = 'h_f(eta_f,eta_g) h_g(eta_f,eta_g) rho_o_f(w_o) rho_o_g(w_o) int_width'
    outputs = 'exodus'
  []
  #------------------------------------------------------------------------------#
  # Conservation check
  [sum_eta]
    type = ParsedMaterial
    property_name = sum_eta
    coupled_variables = 'eta_f eta_g'

    expression= 'eta_f + eta_g'
    # outputs = 'csv'
  []

  [sum_x]
    type = ParsedMaterial
    property_name = sum_x

    expression= 'x_c + x_o + x_co'

    material_property_names = 'x_c x_o x_co'
    # outputs = 'csv'
  []

  [x_V]
    type = ParsedMaterial
    property_name = x_V

    expression= '1 - (x_c + x_o + x_co)'

    material_property_names = 'x_c x_o x_co'
    # outputs = 'csv'
  []

  #------------------------------------------------------------------------------#
  # Average temperature
  [T_fiber] # average T inside the fibers
    type = ParsedMaterial
    property_name = T_fiber
    coupled_variables = 'T'

    expression= 'h_f * T'

    material_property_names = 'h_f'
    outputs = exodus
  []

[] # End of Materials

#------------------------------------------------------------------------------#
[BCs]
  # Top boundary gas in equilibrium
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

  # Fixed temperature gradient
  [fixed_T_top]
    type = DirichletBC
    variable = 'T'
    boundary = 'top'
    value = '2000'
  []

  [fixed_T_bottom]
    type = DirichletBC
    variable = 'T'
    boundary = 'bottom'
    value = '1988'
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

  # nl_abs_tol = 1e-5

  l_max_its = 30
  l_tol = 1.0e-4

  # steady_state_detection = true
  # steady_state_tolerance = 1e-15
  # steady_state_start_time = 1e5

  start_time = 0.0
  # end_time = 1e6

  dtmin = 1e-1
  dtmax = 1e10

  #verbose = true

  automatic_scaling = true
  compute_scaling_once = false

  line_search = default
  line_search_package = petsc

  scheme = bdf2

#  [Adaptivity]
#     # interval = 2
#     refine_fraction = 0.8
#     coarsen_fraction = 0.2
#     max_h_level = 1
#   []
  [TimeStepper]
    type = IterationAdaptiveDT
    dt =  262144 # 262144

    # dt = 1

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
[VectorPostprocessors]
  [grain_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_tracker
    single_feature_per_element = true
    execute_on = 'INITIAL TIMESTEP_END FINAL'
    outputs = none
  []

  [feature_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = feature_counter
    execute_on = 'INITIAL TIMESTEP_END FINAL'
    outputs = none
    single_feature_per_element = false
  []
[]

#------------------------------------------------------------------------------#
[Postprocessors]
  [grain_tracker]
    type = GrainTracker
    variable = 'eta_f eta_g'
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
    execute_on = 'TIMESTEP_END FINAL'
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
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Surface area of fibers
  [surface_area_fiber_gas]
    type = GrainBoundaryArea
    v = 'eta_f eta_g'

    outputs = 'csv'
  []

  # Integral temperature inside the fiber = h_f * T
  [T_fiber_pp]
    type = ElementIntegralMaterialProperty
    mat_prop = 'T_fiber'
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Average temperature inside the fiber
  [Ave_T_fiber]
    type = FunctionValuePostprocessor
    function= 'T_fiber_func'
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Average temperature in the whole domain
  [Ave_T_domain]
    type = AverageNodalVariableValue
    variable = T
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Area integrals
  [int_eta_f]
    type = ElementIntegralVariablePostprocessor
    variable = eta_f
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  [int_eta_g]
    type = ElementIntegralVariablePostprocessor
    variable = eta_g
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Sum of Surface area
  [int_Surface_Area]
    type = ElementIntegralMaterialProperty
    mat_prop = Surface_Area
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    allow_duplicate_execution_on_initial = true

    outputs = 'csv exodus console'
  []
  [int_Surface_Concentration_C]
    type = ElementIntegralMaterialProperty
    mat_prop = Surface_Concentration_C
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    allow_duplicate_execution_on_initial = true

    outputs = 'csv exodus console'
  []
    [int_Surface_Concentration_o]
    type = ElementIntegralMaterialProperty
    mat_prop = Surface_Concentration_o
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    allow_duplicate_execution_on_initial = true

    outputs = 'csv exodus console'
  []
  
  # Species output
  [int_h_f]
    type = ElementIntegralMaterialProperty
    mat_prop = h_f
    execute_on = 'INITIAL TIMESTEP_END FINAL'

    allow_duplicate_execution_on_initial = true

    outputs = 'csv exodus console'
  []

  [int_h_g]
    type = ElementIntegralMaterialProperty
    mat_prop = h_g
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  # Species output
  [total_carbon]
    type = ElementIntegralMaterialProperty
    mat_prop = x_c
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  [total_oxygen]
    type = ElementIntegralMaterialProperty
    mat_prop = x_o
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  [total_mono]
    type = ElementIntegralMaterialProperty
    mat_prop = x_co
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  [out_carbon_fiber]
    type = ElementIntegralMaterialProperty
    mat_prop = x_c_out
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  [out_oxygen_gas]
    type = ElementIntegralMaterialProperty
    mat_prop = x_o_out
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  [out_mono_gas]
    type = ElementIntegralMaterialProperty
    mat_prop = x_co_out
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []

  [omega_chem]
    type = ElementIntegralMaterialProperty
    mat_prop = omega
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []
  [omega_f]
    type = ElementIntegralMaterialProperty
    mat_prop = out_omega_f
    execute_on = 'TIMESTEP_END FINAL'

    outputs = 'csv'
  []
  [omega_g]
    type = ElementIntegralMaterialProperty
    mat_prop = out_omega_g
    execute_on = 'TIMESTEP_END FINAL'

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
  # [area]
  #   type = LevelSetVolume
  #   threshold = 0.5
  #   variable = phi
  #   location = outside
  #   execute_on = 'initial timestep_end'
  # []
[]

#------------------------------------------------------------------------------#
[Outputs]
  file_base = ./results/SpeedSimpleBoxTest_step2

  [console]
    type = Console
    fit_mode = 80
    max_rows = 10
  []

  [exodus]
    type = Exodus
    # append_date = True
    # time_step_interval = 3
  []

  [csv]
    type = CSV
    # append_date = True
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
#   show_var_residual = 'w_c w_o w_co eta_f eta_g T'
# []