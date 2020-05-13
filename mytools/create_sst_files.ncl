ff = addfile("anomaly.nc","r")

latin = ff->latitude(::-1)
lonin = lonFlip(ff->longitude)
sst = lonFlip(ff->anomaly(::-1,:))
lonin(180:) = lonin(180:)+360.0

ntout = 1932 ;1759

latout = (/-87.16,  -83.47,  -79.78,  -76.07,  -72.36,  -68.65,  -64.94, -61.23,  -57.52,  -53.81,  -50.10,  -46.39,  -42.68,  -38.97,  -35.26,  -31.54,  -27.83,  -24.12,  -20.41,  -16.70,  -12.99,   -9.28,   -5.57,   -1.86, 1.86,5.57,    9.28,   12.99,   16.70,   20.41,   24.12,   27.83,   31.54,   35.26, 38.97,   42.68,   46.39,   50.10,   53.81,   57.52,   61.23,   64.94,   68.65, 72.36,   76.07,   79.78,   83.47,   87.16/)

lonout = fspan(0.0,356.25,96)

nlat = dimsizes(latout)
nlon = dimsizes(lonout)

sstout = linint2_Wrap(lonin,latin,sst,True,lonout,latout,1)
delete(sstout@_FillValue)
delete(sstout@missing_value)
printVarSummary(sstout)

do jj = 0, nlat-1
do kk = 0, nlon-1
if(sstout(jj,kk).lt.-10.0) then
sstout(jj,kk) = 0
end if
end do
end do


anom1 = sstout
anom2 = sstout

idxLat1 = ind(latout.le.40.0.or.latout.ge.50.0)
idxLon1 = ind(lonout.le.200.0.or.lonout.ge.215.0)

idxLat2 = ind(latout.le.30.0.or.latout.ge.70.0)
idxLon2 = ind(lonout.le.280.0.or.lonout.ge.350.0)

anom1(idxLat1,:)=0
anom1(:,idxLon1)=0
anom2(idxLat2,:)=0
anom2(:,idxLon2)=0


pacific = anom1
atlantic = anom2
both = anom1+anom2


ofile1 = "pacific.grd"
ofile2 = "atlantic.grd"
ofile3 = "both.grd"

setfileoption("bin","WriteByteOrder","BigEndian")

do ii = 0, ntout-1
ssto = pacific(::-1,:)
fbinrecwrite (ofile1, -1, ssto)
end do
delete(ssto)

do ii = 0, ntout-1
ssto = atlantic(::-1,:)
fbinrecwrite (ofile2, -1, ssto)
end do
delete(ssto)

do ii = 0, ntout-1
ssto = both(::-1,:)
fbinrecwrite (ofile3, -1, ssto)
end do
delete(ssto)
