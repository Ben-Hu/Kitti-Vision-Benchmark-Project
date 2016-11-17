#!/bin/bash
#Set CALIB_DIR to directory of calibration you want to format
CALIB_DIR='/Users/Ben/Desktop/csc420/project/data_road/training/calib/';
#P Matrices
CALIB_ARR=(P0 P1 P2 P3)
for PN in ${CALIB_ARR[@]};do mkdir ${CALIB_DIR}/${PN}/;for i in $(ls ${CALIB_DIR}/*.txt); do NAME=$(basename ${i} .txt); sed -n -e "/^${PN}:/p" ${i}|cut -d ':' -f 2|tr ' ' '\n'|sed '/^$/d'>${CALIB_DIR}/$PN/${PN}_${NAME}.txt;done; done
#R Matrices
mkdir ${CALIB_DIR}/R0; for i in $(ls ${CALIB_DIR}/*.txt); do NAME=$(basename ${i} .txt); sed -n -e "/^R0_rect:/p" ${i}|cut -d ':' -f 2|tr ' ' '\n'|sed '/^$/d'>${CALIB_DIR}/R0/R0_${NAME}.txt;done
#T Matrices
mkdir ${CALIB_DIR}/T0; for i in $(ls ${CALIB_DIR}/*.txt); do NAME=$(basename ${i} .txt); sed -n -e "/^Tr_cam_to_road:/p" ${i}|cut -d ':' -f 2|tr ' ' '\n'|sed '/^$/d'>${CALIB_DIR}/T0/T0_${NAME}.txt;done
