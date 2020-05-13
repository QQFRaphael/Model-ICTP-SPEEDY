# Script to link fortran units to input files; $1 = resolution (t21, t30, ..)

SB=../data/bc/$1/clim
SC=../data/bc/$1/anom
SH=../hflux	

 ln -s $SB/orog_lsm_alb.${1}.grd         fort.20
 ln -s $SB/sst_7908clim.${1}.sea.grd     fort.21
 ln -s $SB/seaice_7908clim.${1}.sea.grd  fort.22
 ln -s $SB/surfv_st3_7908clim.${1}.land.grd   fort.23	
 ln -s $SB/sndep_7908clim.${1}.land.grd  fort.24
 ln -s $SB/veget.${1}.land.grd           fort.25
 ln -s $SB/soilw_7908clim.${1}.land.grd  fort.26

# cp    $SC/hadisst_anom_1_1_1870_2016_mean1979_2008.t30.grd fort.30	
cp ../myfrc/wu5/wu.grd fort.30
	
 cp    $SH/hflux_speedy_ver41.5_1979_2008_clim.grd  fort.31
