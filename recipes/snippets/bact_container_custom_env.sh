#!/bin/bash
if [ -z "$PS1" ]
then
    PS1='bact con. \W > '
else
    PS1="bact con. ${PS1/Apptainer> /} \W > "
    unset tmp
fi
