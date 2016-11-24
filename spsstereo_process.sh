#!/bin/bash
# Run this in PROJ_DIR/results
DATA_L='../data_road/testing/image_2/'
DATA_R='../data_road_right/testing/image_3/'
SPS='../spsstereo/spsstereo'
for I in $(ls $DATA_L); do $SPS "$DATA_L/$I" "$DATA_R/$I"; done