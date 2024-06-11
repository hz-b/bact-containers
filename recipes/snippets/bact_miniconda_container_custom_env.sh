#!/bin/bash
export PATH=/twin/miniconda3/bin/:$PATH
if [ -z "$PS1" ]
then
    PS1='bact con. \W > '
else
    PS1="BOA bact con. ${PS1/Apptainer> /} \W > "
    unset tmp
fi
