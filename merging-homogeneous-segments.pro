pro merging-homogeneous-segments

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

  ;raster
  compile_opt IDL2
  ENVI,/Restore_Base_Save_Files
  e=ENVI()

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
    if area lt 5000 then begin ;
      print,'------------------------xiaoban',xiaoban_plots[j]
      index0 = where(CALData.xiaobanID eq xiaoban_plots[j])
      neighbor = CALData[index0].neighborID 
      lengthid = CALData[index0].length  
      xiao = xiaoban_plots[j]
      number1 = 0
      number2 = 0
      number3 = 0
      nall = []
      c = 5;5
      percent0 = 0.5 ;0.5
      l = 0
      l2 = 0
      l3 = 0
      for i=0UL,n_elements(neighbor)-1  do begin
        ni = neighbor[i]
        n = where(ELEData.xiaobanID eq neighbor[i])
        tree1 = ELEData[index1].treeclass 
        tree2 = ELEData[n].treeclass 
        treepercent1 = ELEData[index1].treepercent 
        treepercent2 = ELEData[n].treepercent 
        mean1 = ELEData[index1].CHM_mean
        mean2 = ELEData[n].CHM_mean 
        canopy1 = ELEData[index1].canopy 
        canopy2 = ELEData[n].canopy 
        cha = abs(mean1-mean2)
        percentcha = abs(treepercent1-treepercent2)
        idx1 = where(data1 eq xiaoban_plots[j])
        if (tree1 eq tree2)  and (percentcha lt percent0) then begin 
          number1=number1+1
          n2 = ni
          idex3 = where(neighbor eq n2)
          length3 = lengthid[idex3]
          nall = [nall,[n2]]
          if length3 gt l2 then begin
            l2 = length3
            n7 = n2 
          endif
        endif
        if cha lt c then begin 
          number3=number3+1
          n3 = ni
          idex1 = where(neighbor eq n3)
          length1 = lengthid[idex1]
          if length1 gt l then begin
            l = length1
            n5 = n3 
          endif
        endif
      endfor
      ;-------------------------------------------
      case number1 of
        1:begin
          data1[idx1] = n2
          print,xiaoban_plots[j],'add to',n2
          openw,lun,outcsv,/get_lun,/append
          printf,lun,xiaoban_plots[j],n2
        end
        0:begin
          ;-------------------------------------------
          case number3 of
            1:begin
              data1[idx1] = n3
              print,xiaoban_plots[j],'add to',n3
              openw,lun,outcsv,/get_lun,/append
              printf,lun,xiaoban_plots[j],n3
            end
            0:begin 
              inter_Max0 = max(CALData[index0].length,Max_Subscript0)
              interid0 = neighbor[Max_Subscript0]
              data1[idx1] = interid0
              print,xiaoban_plots[j],'add to',interid0
              openw,lun,outcsv,/get_lun,/append
              printf,lun,xiaoban_plots[j],interid0
            end
            else:begin 
              data1[idx1] = n5
              print,xiaoban_plots[j],'add to',n5
              openw,lun,outcsv,/get_lun,/append
              printf,lun,xiaoban_plots[j],n5
            end
          endcase
          ;--------------------------------------------
        end
        else:begin
          for q=0UL,n_elements(nall)-1 do begin
            n1 = nall[q]
            n0 = where(ELEData.xiaobanID eq n1)
            mean3 = ELEData[index1].CHM_mean 
            mean4 = ELEData[n0].CHM_mean 
            c1 = abs(mean3-mean4)
            if c1 lt c then begin
              number2=number2+1
              n4 = n1 
              idex2 = where(neighbor eq n4)
              length2 = lengthid[idex2]
              if length2 gt l3 then begin
                l = length2
                n6 = n4
              endif
            endif
          endfor
          ;-------------------------------------------
          case number2 of
            1:begin
              data1[idx1] = n4
              print,xiaoban_plots[j],'add to',n4
              openw,lun,outcsv,/get_lun,/append
              printf,lun,xiaoban_plots[j],n4
            end
            0:begin 
              data1[idx1] = n7
              print,xiaoban_plots[j],'add to',n7
              openw,lun,outcsv,/get_lun,/append
              printf,lun,xiaoban_plots[j],n7
            end
            else:begin 
              data1[idx1] = n6
              print,xiaoban_plots[j],'add to',n6
              openw,lun,outcsv,/get_lun,/append
              printf,lun,xiaoban_plots[j],n6
            end
            ;--------------------------------------------
          endcase
        end
      endcase
      ;-------------------------------------------

      close,/all
    endif
  endfor
  ENVI_Write_ENVI_File,data1,out_name=outfile,map_info=map_info,r_fid=fid
END
