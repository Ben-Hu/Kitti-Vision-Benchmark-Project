LABEL_DIR='./'; mkdir $LABEL_DIR/car_data; 
for f in $(grep -liE 'car' *.txt ); do awk '/Car /' $LABEL_DIR/$f| tee $LABEL_DIR/car_data/$f; done