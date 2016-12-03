#!/bin/bash
DATA_L='../data_road/training/image_2/'
DATA_R='../data_road_right/training/image_3/'
SPS='../spsstereo/spsstereo'
ls $DATA_L
for I in $(ls $DATA_L); do $SPS "$DATA_L/$I" "$DATA_R/$I"; done