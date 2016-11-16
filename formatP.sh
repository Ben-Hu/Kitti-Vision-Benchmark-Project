CALIB_DIR='/Users/Ben/Desktop/csc420/project/data_road/training/calib/';
CALIB_ARR=(P0 P1 P2 P3)
for PN in ${CALIB_ARR[@]};do mkdir ${CALIB_DIR}/${PN}/;for i in $(ls ${CALIB_DIR}/*.txt); do NAME=$(basename ${i} .txt); sed -n -e '/^${PN}:/p' ${i}>${CALIB_DIR}/$PN/${PN}_${NAME}.txt;done; done

