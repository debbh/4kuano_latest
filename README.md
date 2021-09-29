# 2021-09_NWCHEM_to_MicrosoftBroombridge
Initial setup &amp; scaling test on the NWCHEM -> Microsoft Broombridge YAML 2e- generation

## NWCHEM

You need at least version 7.0 .

> conda install -c conda-forge nwchem

Works fine 2021-09-14 .

( The generated YAML mentions NWCHEM 6.8, but this is just inherited from the Schema. Version 6.8 does not seem to contain the code to print out the 2e- integrals)

## NWCHEM run file

You do a standard Hartree-Fock (SCF) calculation. 
The 2e- integrals are then generated by the 'Tensor Contraction Engine' (TCE) block, which is also capable of doing CCSD/CIS/MP2 & related post-HF methods. 

```
tce
  CCSD 

  2eorb
  2emet 13
  tilesize 1

  thresh 1.0d-8
  maxiter 150
  nroots 1 
end

set tce_init:QC T

set tce:print_integrals T
set tce:qorb 6       
set tce:qela 2 
set tce:qelb 2

task tce energy
```

Is the standard approach, which also does a CCSD calculation, which is then extracted as a 'good guess' for the quantum calculation along with the CCSD energy.

Since, setting up a CCSD calculation is computationally very expensive we have used the MBPT2 as an alternative to print the 1 and 2 electron integrals. 

The corresponding yaml generator is the 
## export2YAML_mbpt_energy.py code. 

This python code is explicitly modified to accept the MBPT2 energies from the output file and then convert the 1 and 2 electron integrals into the yaml form. 
This code will give an error message for any other post-HF method other than MBPT2.

## export_chem_library_yaml.py
This code only accepts CCSD energies else will give errors when used with mbpt2 calculations.


## Scaling test

# atoms  elecs  yaml-sto3g   sto3g_out  yaml-631g   631g_out  ( in MB )

#########################################################################
#
    2     4      0.0086       0.028      0.073       0.068      # Lih

    3     10     0.013        0.032      0.104       0.088      # H2O

    2     14     0.027        0.040      0.251       0.171      # N2

    12    42     2.7          1.6        36          20         # Benzene

    24    94     219          122         -            -        # Anthracene
#
#########################################################################

#

# H2O basis set comparison for yaml files

#  sto-3g  6-31g  6-311g   cc-pVDZ   cc-pVTZ  (in MB)
--------------------------------------------------
#   0.013   0.104   0.426   0.902      27


## TODO

 - [Done upto Anthracene] Scaling test
 - [Done] Edit Python file to accept perturbation-theory originating 2e- integrals
 - [Prints everything] Understand the NWCHEM failure when outputing MBPT2 methods; not able to print something?

The only issue here is the time constraint. 
Anthracene (24 atoms with 94 electrons) took over 6 hours (real time) to simply print the 1 and 2 electron intergrals. MBPT2 calculations was not over yet. 
However, if the goal is simply to get the 1 and 2 electron intergrals and not the final MBPT2 energies (which was the case here), we can use that output file and append it with the following lines to be able to pass it through the python code and get the integrals in YAML format. 

In order to append an incomplete output file use the following command:
cat output_file tail_end_file > appended_output 

where, ### tail_end_file is simply the end part of a sample mbpt2 calculation. Please note, the final mbpt2 energy in this case wil lbe incorrect, but since the HF calculations were correct, the integrals will be correct. 
This technique can save computational time, however it means the user needs to keep a live tab on the output file.
