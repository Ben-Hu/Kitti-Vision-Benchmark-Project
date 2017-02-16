# Road and Object Detection 
Dependencies:

dpm-https://people.eecs.berkeley.edu/~rbg/latent/

libsvm-http://www.csie.ntu.edu.tw/~cjlin/libsvm/

spsstereo-http://ttic.uchicago.edu/~dmcallester/SPS/ (optional, can CV toolbox disparity)

Matlab Computer Vision Toolbox

To Run:
Kitti Data structure:
./data_road_right/[training|testing]
./data_road/[training|testing]
./data_car_left/[training|testing]

run 
format_calib.sh (set CALIB_DIR to data_x/.../calib)
filter_car_data.sh (set LABEL_DIR to data_x/.../label_2)
spsstereo_process.sh (set directories to Left and Right images)
To get data processed in formats code uses, set in globals.

p2main.m is a script that will generate a 3d point cloud with 3d bounding boxes for detected cars and also output a 2d image with 3d boxes represented in 2d along with the road classifier segmentation result. 

fitPlanePipe.m can be used to fit a plane to the surface of the road

#Example Results

[![Road Segmentation](https://img.youtube.com/vi/HpAEFAEHcrU/0.jpg)](https://www.youtube.com/watch?v=HpAEFAEHcrU)

[![Road & Object Detection](https://img.youtube.com/vi/KgDvll4nblw/0.jpg)](https://www.youtube.com/watch?v=KgDvll4nblw)

![Point Clouds](https://raw.githubusercontent.com/Ben-Hu/Kitti-Vision-Benchmark-Project/master/img/pc_box1.png)

![Point Clouds](https://raw.githubusercontent.com/Ben-Hu/Kitti-Vision-Benchmark-Project/master/img/pc_box2.png)
