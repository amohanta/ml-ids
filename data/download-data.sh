#!/bin/bash

# URL format:
# https://www.ll.mit.edu/ideval/data/1999/training/week2/monday/outside.tcpdump.gz

base_url="https://www.ll.mit.edu/ideval/data/1999/"

mkdir -p training
mkdir -p testing
mkdir -p kdd_data

echo "Downloading the DARPA 1999 IDS Dataset..."

for dataset in "training" "testing"; do
  if [ $dataset = "training" ]; then
    for week in "week1" "week2" "week3"; do
      for weekday in "monday" "tuesday" "wednesday" "thursday" "friday"; do
        echo wget $base_url$dataset/$week/$weekday/inside.tcpdump.gz
        wget $base_url$dataset/$week/$weekday/inside.tcpdump.gz -O $dataset/$week\_$weekday\_inside.gz -q
        gunzip $dataset/$week\_$weekday\_inside.gz

        # Also grab the 3 additional days of extra data from week 3
        if [ $week = "week3" ]; then
          if [ $weekday = "monday" ] || [ $weekday = "tuesday" ] || [ $weekday = "wednesday" ]; then
            echo wget $base_url$dataset/$week/extra\_$weekday/inside.tcpdump.gz
            wget $base_url$dataset/$week/extra\_$weekday/inside.tcpdump.gz -O $dataset/$week\_$weekday\_extra\_inside.gz -q
            gunzip $dataset/$week\_$weekday\_extra\_inside.gz 
          fi
        fi

      done
    done
  else 
    for week in "week4" "week5"; do
      for weekday in "monday" "tuesday" "wednesday" "thursday" "friday"; do
        echo wget $base_url$dataset/$week/$weekday/inside.tcpdump.gz
        wget $base_url$dataset/$week/$weekday/inside.tcpdump.gz -O $dataset/$week\_$weekday\_inside.gz -q 
        gunzip $dataset/$week\_$weekday\_inside.gz 
      done
    done
  fi
done

# This dataset does not exist. Remove this dummy file
rm testing/week4_tuesday_inside.gz

echo "Downloading the KDD 1999 Dataset..."

echo wget http://kdd.ics.uci.edu/databases/kddcup99/kddcup.data_10_percent.gz
wget http://kdd.ics.uci.edu/databases/kddcup99/kddcup.data_10_percent.gz -O kdd_data/training.gz -q
gunzip kdd_data/training.gz 


echo wget http://kdd.ics.uci.edu/databases/kddcup99/corrected.gz
wget http://kdd.ics.uci.edu/databases/kddcup99/corrected.gz -O kdd_data/testing.gz -q
gunzip kdd_data/testing.gz 

echo wget https://archive.ics.uci.edu/ml/machine-learning-databases/kddcup99-mld/kddcup.names
wget https://archive.ics.uci.edu/ml/machine-learning-databases/kddcup99-mld/kddcup.names -O kdd_data/kddcup.names -q

echo "Preprocessing KDD data..."
python parse_kdd_data.py || { exit 1; }

echo "Done!"
