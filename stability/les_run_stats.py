#!/usr/bin/env python

import numpy as np
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from netCDF4 import Dataset as NC
from os.path import join
from glob import glob
import multiprocessing as mp

def get_run_stats(tasks, processor_hours):
        while True:
            m_file = tasks.get()
            if not isinstance(m_file, str):
                print('[%s] evaluation routine quits' % process_name)

                # Indicate finished
                processor_hours.put(0)
                break
            else:           
                print(m_file)
                nc = NC(m_file, 'r')
                run_stats = nc.variables['run_stats']
                processor_hours.put(run_stats.processor_hours)
                nc.close()
        return


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.description = "Generate tables for the paper"
    parser.add_argument("--prefix", dest="prefix",
                        help="the directory containing output files from the study",
                        default="/import/c1/ICESHEET/aaschwanden/pism-gris/stability/2018_01_les/state/")
    options = parser.parse_args()

    manager = mp.Manager()

    # Define a list (queue) for tasks and computation results
    tasks = manager.Queue()
    processor_hours = mp.Queue()

    num_processes = 4
    pool = mp.Pool(processes=num_processes)  
    processes = []
    
    for i in range(num_processes):

        # Set process name
        process_name = 'P%i' % i

        # Create the process, and connect it to the worker function
        new_process = mp.Process(target=get_run_stats, args=(tasks, processor_hours))

        # Add new process to the list of processes
        processes.append(new_process)

        # Start the process
        new_process.start()

    # Fill task queue
    all_files = glob(join(options.prefix, 'gris_g1800m*.nc'))
    task_list = all_files
    for single_task in task_list:  
        tasks.put(single_task)

    for i in range(num_processes):  
        tasks.put(0)

    # Read calculation results
    num_finished_processes = 0  
    while True:  
        # Read result
        new_result = processor_hours.get()

        # Have a look at the results
        if new_result == 0:
            # Process has finished
            num_finished_processes += 1

            if num_finished_processes == num_processes:
                break
        else:
            # Output result
            print('Result: ' + str(new_result))
    
    # all_files = glob(join(options.prefix, 'gris_g1800m_*.nc'))
    # nf = len(all_files)
    # processor_hours = np.zeros((nf))
    # wall_clock_hours = np.zeros((nf))
    # for k, m_file in enumerate(all_files):
    #     nc = NC(m_file, 'r')
    #     run_stats = nc.variables['run_stats']
    #     processor_hours[k] = run_stats.processor_hours
    #     wall_clock_hours[k] = run_stats.wall_clock_hours
    #     nc.close()

    # total_processesor_hours = np.sum(processor_hours)
    # print('Total processor hours: {5.0f}'.format(processor_hours))
        
