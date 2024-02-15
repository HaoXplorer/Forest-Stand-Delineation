pro eliminating-small-segments

  ;raster
  compile_opt IDL2
  ENVI,/Restore_Base_Save_Files
  e=ENVI()
  ;attributes
  csvfile="segment_attributes.csv"  
  intersectfile='length of the common edge.csv' 
  outcsv = "out.csv"
  data2 = read_csv(intersectfile)
  treeCAL = {CAL, xiaobanID:0UL,neighborID:0UL,length:0.0}
  CALData = replicate(treeCAL, n_elements(data2.field1))
  CALData.xiaobanID = data2.field1
  CALData.neighborID = data2.field2
  CALData.length = data2.field3

  data = read_csv(csvfile)
  elementCAL = {ELE, xiaobanID:0UL,AREA:0UL,CHM_mean:0.0,canopy:0.0,treeclass:0UL,treepercent:0.0}
  ELEData = replicate(elementCAL, n_elements(data.field1))
  ELEData.xiaobanID = data.field1
  ELEData.AREA = data.field2
  ELEData.CHM_mean = data.field3
  ELEData.canopy = data.field4
  ELEData.treeclass = data.field5
  ELEData.treepercent = data.field6

  filename="segments.dat" 
  outfile="merged_segments.dat" 
  ;Use ENVI tools
  ENVI_OPEN_FILE,filename,r_fid=fid
  ENVI_FILE_QUERY,fid,fname=fname,dims=dims,nb=nb,map_info = map_info
  IF (fid EQ -1) THEN BEGIN
    RETURN
  ENDIF

  map_info=envi_get_map_info(fid=fid)
  proinfo=envi_get_projection(fid=fid)
  ;get data
  data1 = ENVI_GET_DATA(fid=fid, dims=dims, pos=0) ;shp

  xiaoban_plots=data.field1[uniq(data.field1)]
  for j=0,n_elements(xiaoban_plots)-1  do begin
    index1 = where(ELEData.xiaobanID eq xiaoban_plots[j])
    area = ELEData[index1].AREA
    print,'------------------------xiaoban',xiaoban_plots[j]
    index0 = where(CALData.xiaobanID eq xiaoban_plots[j])
    neighbor = CALData[index0].neighborID 
    idx1 = where(data1 eq xiaoban_plots[j])
    c = 100
    n2 = xiaoban_plots[j]
    mean1 = ELEData[index1].CHM_mean 
    tree1 = ELEData[index1].treeclass 
    treepercent1 = ELEData[index1].treepercent 
    canopy1 = ELEData[index1].canopy 
    case tree1 of
      6:begin
        for i=0UL,n_elements(neighbor)-1  do begin
          ni = neighbor[i]
          n = where(ELEData.xiaobanID eq neighbor[i]) 
          area2 = ELEData[n].AREA
          fullarea = area + area2
          if fullarea lt 500000 then begin 
            tree2 = ELEData[n].treeclass 
            treepercent2 = ELEData[n].treepercent 
            mean2 = ELEData[n].CHM_mean 
            canopy2 = ELEData[n].canopy 
            cha = abs(mean1-mean2)
            percentcha = abs(treepercent1-treepercent2)
            canopycha = abs(canopy1-canopy2)
            if (tree1 eq tree2)and (percentcha lt 0.5)and (canopycha lt 0.1) and (cha lt 3) then begin 
              if cha lt c then begin
                c = cha
                n2 = ni
              endif
            endif
          endif
        endfor
        data1[idx1] = n2
        print,xiaoban_plots[j],'add to',n2
        openw,lun,outcsv,/get_lun,/append
        printf,lun,xiaoban_plots[j],n2
      end
      else:begin
        for i=0UL,n_elements(neighbor)-1  do begin
          ni = neighbor[i]
          n = where(ELEData.xiaobanID eq neighbor[i])
          area2 = ELEData[n].AREA
          fullarea = area + area2
          if fullarea lt 200000 then begin  
            tree2 = ELEData[n].treeclass
            treepercent2 = ELEData[n].treepercent 
            mean2 = ELEData[n].CHM_mean 
            canopy2 = ELEData[n].canopy 
            cha = abs(mean1-mean2)
            percentcha = abs(treepercent1-treepercent2)
            canopycha = abs(canopy1-canopy2)
            if (tree1 eq tree2)and (percentcha lt 0.5) and (canopycha lt 0.2) and (cha lt 3) then begin 
              if cha lt c then begin
                c = cha
                n2 = ni
              endif
            endif
          endif
        endfor
        data1[idx1] = n2
        print,xiaoban_plots[j],'add to',n2
        openw,lun,outcsv,/get_lun,/append
        printf,lun,xiaoban_plots[j],n2
      end
    endcase
    close,/all

  endfor
  ENVI_Write_ENVI_File,data1,out_name=outfile,map_info=map_info,r_fid=fid
END
