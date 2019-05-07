#!/bin/sh

RED='\033[0;31m'
NC='\033[0m'

# Verifies if variable is set and adds 
# the name to 'fields' variable if not.
#
# argument: field_name field_value
#
assertFieldExists() {
    if [ -z "$2" ];  then
        result=
        if [ -z "$fields" ];  then
            fields="$1"
        else
            fields="$fields, $1"
        fi        
    fi
}

# Adds a command line argument to the list of all 
# arguments. This is stored in the 'arg_list' variable 
# as "--<arg_name>=<arg_value>".
#
# argument: arg_name arg_value
#
addArg() {
    if [ ! -z "$2" ];  then
        if [ -z "$arg_list" ];  then
            arg_list="--$1=$2"
        else
            arg_list="$arg_list --$1=$2"
        fi        
    fi
}
