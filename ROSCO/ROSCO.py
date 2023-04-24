# This script runs ROSCO controller using libdiscon.dll file and .yaml file to generate DISCON.IN, and runs OpenFAST to generate too (Anaconda required)
# Load required Python modules
import os
import matplotlib.pyplot as plt
import pprint
import numpy as np

# Load required ROSCO toolbox modules
from ROSCO_toolbox import turbine as ROSCO_turbine
from ROSCO_toolbox import utilities as ROSCO_utilities
from ROSCO_toolbox import controller as ROSCO_controller
from ROSCO_toolbox import control_interface as ROSCO_ci
from ROSCO_toolbox import sim as ROSCO_sim
from ROSCO_toolbox.ofTools.fast_io.output_processing import output_processing
from ROSCO_toolbox.inputs.validation import load_rosco_yaml
from ROSCO_toolbox.utilities import run_openfast

# Loading NREL 5-MW tuning.YAML file and reading parameters
this_dir = os.path.dirname(os.path.abspath(__file__))
tuning_yaml_filename = os.path.join(this_dir,'5MW_ITIBarge_DLL_WTurb_WavesIrr.yaml')
tuning_yaml = load_rosco_yaml (tuning_yaml_filename)
path_params = tuning_yaml['path_params']
turbine_params = tuning_yaml['turbine_params'] 
controller_params = tuning_yaml['controller_params']

# Load turbine data from openfast model
turbine = ROSCO_turbine.Turbine(turbine_params)
turbine.load_from_fast(path_params['FAST_InputFile'],os.path.join(this_dir,path_params['FAST_directory']),rot_source='txt',txt_filename=path_params['rotor_performance_filename'])

# tuning the ROSCO controller
controller = ROSCO_controller.Controller(controller_params)
controller.tune_controller(turbine)

# writing DISCON.IN file
discon_file = 'DISCON.IN'
ROSCO_utilities.write_DISCON(turbine,controller,param_file=discon_file, txt_filename=path_params['rotor_performance_filename'])

# Specify controller dynamic library path and name
lib_name = './libdiscon.dll'

# Load the simulator and controller interface
controller_int = ROSCO_ci.ControllerInterface(lib_name)
sim = ROSCO_sim.Sim(turbine, controller_int)

# Run OpenFAST
fastcall = 'openfast_x64.exe'
run_openfast(path_params['FAST_directory'],fastcall = fastcall,fastfile=path_params['FAST_InputFile'],chdir=True)