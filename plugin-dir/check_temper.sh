#!/bin/bash

#######################################################
#                                                     #
#  Name:    check_temper                              #
#                                                     #
#  Version: 1.3                                       #
#  Created: 2012-05-29                                #
#  License: GPL - http://www.gnu.org/licenses         #
#  Copyright: (c)2013 ovido gmbh                      #
#  Author:  Rene Koch <r.koch@ovido.at>               #
#  URL: https://labs.ovido.at/monitoring              #
#                                                     #
#######################################################

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Changelog:
# * 1.3.0 - Wed Mar 27 2013 - Rene Koch <r.koch@ovido.at>
# - First public release under GPL
# * 1.2.0 - Thu Jun 28 2012 - Rene Koch <r.koch@ovido.at>
# - Changed warning and critical values to range
# * 1.1.0 - Tue May 29 2012 - Rene Koch <r.koch@ovido.at>
# - Added humidity check
# * 1.0.0 - Tue May 29 2012 - Rene Koch <r.koch@ovido.at>
# - This is the first release of new plugin check_temper

# Configuration
TEMPERED="/usr/local/bin/tempered"

# Create performance data
# 0 ... disabled
# 1 ... enabled
PERFDATA=1

# Variables
PROG="check_temper"
VERSION="1.3"
VERBOSE=0
CHECK="temp"

# Icinga/Nagios status codes
STATUS_WARNING=1
STATUS_CRITICAL=2
STATUS_UNKNOWN=3


# function print_usage()
print_usage(){
  echo "Usage: ${0} [-v] [-w <warn>] [-c <critical>] [-V] [-C temp|hum]"
}


# function print_help()
print_help(){
  echo ""
  echo "TEMPer temperature plugin for Icinga/Nagios version $version"
  echo "(c)2013 - Rene Koch <r.koch@ovido.at>"
  echo ""
  echo ""
  print_usage
  cat <<EOT

Options:
 -h, --help
    Print detailed help screen
 -V, --version
    Print version information
 -w, --warning=RANGE
    Generate warning state if metric is outside this range
 -c, --critical=RANGE
    Generate warning state if metric is outside this range
 -C, --check=temp|hum
    Check either temperature or humidity
    default: temp
 -v, --verbose
    Show details for command-line debugging (Nagios may truncate output)

Send email to r.koch@ovido.at if you have questions regarding use
of this software. To sumbit patches of suggest improvements, send
email to r.koch@ovido.at
EOT

exit ${STATUS_UNKNOWN}

}


# function print_version()
print_version(){
  echo "${PROG} ${VERSION}"
  exit ${STATUS_UNKNOWN}
}


# function get_temperature
# Get temperature from TEMPer
get_temperature(){
  TEMPER=`${TEMPERED} 2>&1`
  if [ $? -ne 0 ]; then
    echo "Temperature UNKNOWN: ${TEMPER}"
    exit ${STATUS_UNKNOWN}
  else
    # Get temperature
    TEMP=`echo ${TEMPER} | cut -d' ' -f4 | cut -d'°' -f1`

    # Check if temperature is CRITICAL
    if [ ${CRIT_MAX} ]; then
      if [ `echo "${TEMP} > ${CRIT_MAX}" | bc` -eq 1 ] || [ `echo "${TEMP} < ${CRIT_MIN}" | bc` -eq 1 ]; then
        STATUSTEXT="Temperature CRITICAL: ${TEMP}°C"
        STATUS=${STATUS_CRITICAL}
        return
      fi
    fi
    
    # Check if temperature is WARNING
    if [ ${WARN_MAX} ]; then
      if [ `echo "${TEMP} > ${WARN_MAX}" | bc` -eq 1 ] || [ `echo "${TEMP} < ${WARN_MIN}" | bc` -eq 1 ]; then
        STATUSTEXT="Temperature WARNING: ${TEMP}°C"
        STATUS=${STATUS_WARNING}
        return
      fi
    fi 
    
    # Temperature is OK
    STATUSTEXT="Temperature OK: ${TEMP}°C"
    STATUS=${STATUS_OK}
  fi
}


# function get_humidity
# Get humidity from TEMPer
get_humidity(){
  TEMPER=`${TEMPERED} 2>&1`
  if [ $? -ne 0 ]; then
    echo "Humidity UNKNOWN: ${TEMPER}"
    exit ${STATUS_UNKNOWN}
  else
    # Get humidity
    HUM=`echo ${TEMPER} | cut -d' ' -f7 | cut -d'%' -f1`

    # Check if humidity is CRITICAL
    if [ ${CRIT_MAX} ]; then
      if [ `echo "${HUM} > ${CRIT_MAX}" | bc` -eq 1 ] || [ `echo "${HUM} < ${CRIT_MIN}" | bc` -eq 1 ]; then
        STATUSTEXT="Humidity CRITICAL: ${HUM}%"
        STATUS=${STATUS_CRITICAL}
        return
      fi
    fi
    
    # Check if humidity is WARNING
    if [ ${WARN_MAX} ]; then
      if [ `echo "${HUM} > ${WARN_MAX}" | bc` -eq 1 ] || [ `echo "${HUM} < ${WARN_MIN}" | bc` -eq 1 ]; then
        STATUSTEXT="Humidity WARNING: ${HUM}%"
        STATUS=${STATUS_WARNING}
        return
      fi
    fi 
    
    # Humidity is OK
    STATUSTEXT="Humidity OK: ${HUM}%"
    STATUS=${STATUS_OK}
  fi
}


# The main function starts here

# Parse command line options
while test -n "$1"; do
  
  case "$1" in
    -h | --help)
      print_help
      ;;
    -V | --version)
      print_version
      ;;
    -v | --verbose)
      VERBOSE=1
      shift
      ;;
    -w | --warning)
      if [[ ${2} == *:* ]]; then
        WARN_MIN=`echo ${2} | cut -d: -f1`
        WARN_MAX=`echo ${2} | cut -d: -f2`
      else
	echo "Invalid warning range: ${2}"
	print_usage
	exit ${STATUS_UNKNOWN}
      fi
      shift
      ;;
    -c | --critical)
      if [[ ${2} == *:* ]]; then
        CRIT_MIN=`echo ${2} | cut -d: -f1`
        CRIT_MAX=`echo ${2} | cut -d: -f2`
      else
        echo "Invalid critical range: ${2}"
        print_usage
        exit ${STATUS_UNKNOWN}
      fi
      shift
      ;;
    -C | --check)
      CHECK=${2}
      shift
      ;;
    *)
      echo "Unknown argument: ${1}"
      print_usage
      exit ${STATUS_UNKNOWN}
      ;;
  esac
  shift
      
done


# Check if script is started with as user root (or sudo is used)
if [ `whoami` != "root" ]; then
  echo "Temperature UNKNOWN: sudo or root privileges are required!"
  exit ${STATUS_UNKNOWN}
fi


# Check if bc is installed
if [ `which bc` != "/usr/bin/bc" ]; then
  echo "Temperature UNKNOWN: bc not found!"
  exit ${STATUS_UNKNOWN}
fi


# What to check
if [ "${CHECK}" == "temp" ]; then
  get_temperature
elif [ "${CHECK}" == "hum" ]; then
  get_humidity
else
  echo "Unknown check defined"
  print_usage
  exit ${STATUS_UNKNOWN}
fi


# Check if perfdata is given
if [ ${PERFDATA} -eq 1 ]; then
  if [ -z ${WARN_MAX} ]; then
    WARN_MAX=""
  fi
  if [ -z ${CRIT_MAX} ]; then
    CRIT_MAX=""
  fi
  if [ ${CHECK} == "temp" ]; then
    PERF="'temp'=${TEMP};${WARN_MAX};${CRIT_MAX};;"
  else
    PERF="'hum'=${HUM}%;${WARN_MAX};${CRIT_MAX};;"
  fi
  echo "${STATUSTEXT}|$PERF"
else
  echo ${STATUSTEXT}
fi

exit ${STATUS}

