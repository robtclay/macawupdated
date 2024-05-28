#include "macawApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
macawApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_uo_initialization") = false;
  params.set<bool>("use_legacy_uo_aux_computation") = false;
  params.set<bool>("use_legacy_output_syntax") = false;
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;

  return params;
}

macawApp::macawApp(InputParameters parameters) : MooseApp(parameters)
{
  macawApp::registerAll(_factory, _action_factory, _syntax);
}

macawApp::~macawApp() {}

void
macawApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  //Vishal ModulesApp::registerAll(f, af, syntax);
  ModulesApp::registerAllObjects<macawApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"macawApp"});
  Registry::registerActionsTo(af, {"macawApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
macawApp::registerApps()
{
  registerApp(macawApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
macawApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  macawApp::registerAll(f, af, s);
}
extern "C" void
macawApp__registerApps()
{
  macawApp::registerApps();
}
