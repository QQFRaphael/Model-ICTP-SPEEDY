#!/bin/sh

# model setups
# nmonths: run months
# icland:  coupling flag for land surface temp, 0 is no, 1 is land model
# icsea:   coupleing flag for sea surface temp, 0 is prescribe
# icice:   coupleing flag for sea ice temp, 0 is no, 1 is ice model
# isstan:  SST anomaly flag, 0 is no, only clim SST, 1 is oberved anomaly
nmonths=3600
ICLAND=1
ICSEA=0
ICICE=1
ISSTAN=1

# $res = resolution (eg t21, t30)
# $expno = experiment no. (eg 111)
# $exprsno = experiment no. for restart file ( 0 = no restart ) 

res='t30'
expno='004'
exprsno=0

# SST anomaly file
sstfile="..\/myfrc\/wu5\/wu.grd"
sed -i "16s/^.*.$/cp $sstfile fort.30/g" ../ver41.5.input/inpfiles.s

# modify namelist

sed -i "4s/^.*.$/      NMONTS = $nmonths/g" ../ver41.5.input/cls_instep.h 
sed -i "22s/^.*.$/      ICLAND = $ICLAND/g" ../ver41.5.input/cls_instep.h 
sed -i "23s/^.*.$/      ICSEA  = $ICSEA/g" ../ver41.5.input/cls_instep.h 
sed -i "24s/^.*.$/      ICICE  = $ICICE/g" ../ver41.5.input/cls_instep.h 
sed -i "25s/^.*.$/      ISSTAN = $ISSTAN/g" ../ver41.5.input/cls_instep.h 


# Define directory names
# set -x

UT=..	
SA=$UT/source
CA=$UT/tmp
mkdir $UT/output/exp_$expno
CB=$UT/output/exp_$expno
CC=$UT/ver41.5.input
CD=$UT/output/exp_$exprsno	

mkdir $UT/input/exp_$expno

echo "model version   :   41"  > $UT/input/exp_$expno/run_setup
echo "hor. resolution : " $res  >> $UT/input/exp_$expno/run_setup
echo "experiment no.  : " $expno  >> $UT/input/exp_$expno/run_setup
echo "restart exp. no.: " $exprsno  >> $UT/input/exp_$expno/run_setup
	
# Copy files from basic version directory

echo "copying from $SA/source to $CA"
rm -f $CA/*

cp $SA/makefile $CA/
cp $SA/*.f      $CA/
cp $SA/*.h      $CA/
cp $SA/*.s      $CA/

cp $CA/par_horres_$res.h   $CA/atparam.h
cp $CA/par_verres.h      $CA/atparam1.h 

# Copy parameter and namelist files from user's .input directory

echo "ver41.input new files ..."
ls $UT/ver41.5.input

echo "copying parameter and namelist files from $UT/ver41.input "
cp $UT/ver41.5.input/cls_*.h     $CA/
cp $UT/ver41.5.input/inpfiles.s  $CA/
cp $UT/ver41.5.input/cls_*.h     $UT/input/exp_$expno
cp $UT/ver41.5.input/inpfiles.s  $UT/input/exp_$expno

# Copy modified model files from user's update directory

echo "update new files ..."
ls $UT/update

echo "copying modified model files from $UT/update"
cp $UT/update/*.f   $CA/
cp $UT/update/*.h   $CA/
cp $UT/update/make* $CA/	
cp $UT/update/*.f   $UT/input/exp_$expno
cp $UT/update/*.h   $UT/input/exp_$expno
cp $UT/update/make* $UT/input/exp_$expno
			
# Set input files

cd $CA

# Set experiment no. and restart file (if needed)

echo $exprsno >  fort.2
echo $expno >> fort.2

if [ $exprsno != 0 ] ; then
  echo "link restart file atgcm$exprsno.rst to fort.3"
  ln -s $CD/atgcm$exprsno.rst fort.3
fi 

# Link input files

echo 'link input files to fortran units'

sh inpfiles.s $res

ls -l fort.*

echo ' compiling at_gcm - calling make'

make imp.exe  

#
# create and execute a batch job to run the model
#

cat > run.job.sh << EOF1
#!/bin/sh
set -x
 
cd $CA
pwd


echo 'the executable file...'
ls -l imp.exe

 
time ./imp.exe > out.lis

mv out.lis $CB/atgcm$expno.lis
mv fort.10 $CB/atgcm$expno.rst

mv at*$expno.ctl   $CB
mv at*$expno_*.grd $CB

mv day*$expno.ctl   $CB
mv day*$expno_*.grd $CB

cd $CB

chmod 644 at*$expno.* 

EOF1
chmod u+x run.job.sh


nohup sh run.job.sh &


