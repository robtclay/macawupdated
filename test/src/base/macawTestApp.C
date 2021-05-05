//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "macawTestApp.h"
#include "macawApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
macawTestApp::validParams()
{
  InputParameters params = macawApp::validParams();
  return params;
}

macawTestApp::macawTestApp(InputParameters parameters) : MooseApp(parameters)
{
  macawTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

macawTestApp::~macawTestApp() {}

void
macawTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  macawApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"macawTestApp"});
    Registry::registerActionsTo(af, {"macawTestApp"});
  }
}

void
macawTestApp::registerApps()
{
  registerApp(macawApp);
  registerApp(macawTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
macawTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  macawTestApp::registerAll(f, af, s);
}
extern "C" void
macawTestApp__registerApps()
{
  macawTestApp::registerApps();
}
