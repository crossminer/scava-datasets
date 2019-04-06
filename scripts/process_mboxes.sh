##################################################################
#
# Copyright (C) 2019 Castalia Solutions
# 
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
# 
# SPDX-License-Identifier: EPL-2.0
#
###################################################################


DATE=`date +%Y-%m-%d`
dir_session=/tmp/r_extract_project_${DATE}.session
dir_anon="data-anonymiser"
url_anon="https://github.com/borisbaldassari/data-anonymiser/archive/master.zip"

run_csv=1
run_mbox=1

echo "# Checking if anonymisation utility is present.."
if [ -e ${dir_anon}/code/anonymise ]; then
    echo "  * Found [${dir_anon}/code/anonymise] utility."
else
    echo "  * Cannot find [${dir_anon}/code/anonymise] utility."
    echo "    Downloading utility from [$url_anon].."
    curl -L -s ${url_anon} -o data-anonymiser.zip
    echo "    Uncompressing utility to ${dir_anon}."
    unzip -q data-anonymiser.zip
    mv data-anonymiser-master/ data-anonymiser/
fi

echo "# Creating session directory [${dir_session}]."
if [ -e $dir_session ]; then
    echo "  * Removing old session dir."
    mv $dir_session ${dir_session}.old
fi

if [ $run_csv -eq 1 ]; then
    echo "# Regenerating CSV files.."

    if [ -d csv/ ]; then
	rm -rf csv/
    fi
    mkdir -p csv/

    for f in `ls scava/`; do 
	echo "* Working on mbox $f"
	perl mbox2csv.pl scava/$f
	mv $f.csv csv/
    done

    # Generate a single big file with all csv's
    cat headers.init > eclipse_mls_full.csv
    cat csv/*.csv >> eclipse_mls_full.csv

    echo "# Anonymising csv dataset"
    perl anonymise_csv.pl eclipse_mls_full.csv
    mv eclipse_mls_clean.csv eclipse_mls_full.csv
    
    echo "# Creating archive eclipse_mls_full.csv.gz"
    gzip eclipse_mls_full.csv
    
    echo "# Moving eclipse_mls_full.gz to datasets directory..."
    mv eclipse_mls_full.csv.gz ../datasets/eclipse_mls/

    echo "# Cleaning workspace"
    rm -rf csv/
fi

if [ $run_mbox -eq 1 ]; then
    echo "# Anonymise mboxes.."
    
    if [ -d scava_scrambled/ ]; then
	rm -rf scava_scrambled/
    fi
    mkdir -p scava_scrambled/
    
    for f in `ls scava/`; do 
	echo "* Working on mbox $f"
	perl data-anonymiser/code/anonymise scramble -s $dir_session \
             -f scava/$f -t scava_scrambled/${f}
	gzip scava_scrambled/${f}
    done
    
    if [ -d ../datasets/eclipse_mls/mboxes/ ]; then
	rm -rf ../datasets/eclipse_mls/mboxes/
    fi
    mkdir -p ../datasets/eclipse_mls/mboxes/
    
    echo "# Moving mls results to datasets directory..."
    mv scava_scrambled/* ../datasets/eclipse_mls/mboxes/
fi

echo "# Removing session directory [${dir_session}]."
rm -rf $dir_session

