load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

case="WANG"

f1 = addfile("CTL.nc", "r")
f2 = addfile("wang.nc", "r")

ctl = f1->gh
snt = f2->gh

anom = (snt-ctl)
copy_VarMeta(ctl, anom)

Hgt_anom = (anom(2::12,3,:,:)+anom(3::12,3,:,:)+anom(4::12,3,:,:))/3.0
copy_VarMeta(anom(0:99,3,:,:), Hgt_anom)

diff = dim_avg_n_Wrap(Hgt_anom(40:99,:,:), 0)


lat = f1->lat
lon = f1->lon

res = True
res@gsnDraw=False
res@gsnFrame=False
res@gsnSpreadColors=True
res@gsnMaximize=True


res@mpMinLatF              =  10
  res@mpMaxLatF              =  90
  res@mpMinLonF              = 120
  res@mpMaxLonF              = 330
res@mpCenterLonF=180


  res@mpGridAndLimbOn        = False  
res@pmTickMarkDisplayMode  = "Always"
res@mpGridLatSpacingF      = 15
res@mpGridLonSpacingF      = 15

res@mpGridLineDashPattern  = 5

res@cnLineThicknessF = 3

res@mpLandFillColor="white"

res@cnFillOn=True
res@cnLinesOn=True
res@cnLineLabelsOn=False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels=fspan(-20,20,21)
;res@cnFillColors=(/2,18,34,50,66,82,0,0,146,162,178,194,210,226,242,255/)

res@lbOrientation="Vertical"

;res@cnFillOpacityF=0.8

res@gsnLeftString=""
res@gsnRightString=""

wks = gsn_open_wks("png", case)
gsn_define_colormap(wks,"myblrd")


map = gsn_csm_contour_map(wks, diff, res)
map = ColorNegDashZeroPosContour(map,"black",0,"black")

draw(map)
frame(wks)
