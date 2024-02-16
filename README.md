# Forest-Stand-Delineation
For the automated delineation of forest stands, we offer code for merging homogeneous segments and eliminating small segments.   
This method is based on our paper titled ***"Forest Stand Delineation Using Airborne LiDAR and Hyperspectral Data"***.   

**The delineation process involves three main steps**:   
(1) downsampling the 1 m resolution Canopy Height Model (CHM) to 5 m, applying a minimum variance filter, and oversegmenting to obtain segments smaller than the forest stand size;   
(2) calculating segment attributes such as mean canopy height, canopy closure, dominant tree species, and the proportion of dominant tree species;   
(3) utilizing two rules (merging homogeneous segments and eliminating small segments) to merge segments into final forest stands.   

**The code implementing these two rules is provided in this GitHub repository.**  

