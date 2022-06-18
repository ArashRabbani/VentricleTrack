# VentricleTrack
## Temporal extrapolation of heart wall segmentation in cardiac magnetic resonance images via pixel tracking
In this repository, we have tailored a pixel tracking method for temporal extrapolation of the ventricular segmentation masks in cardiac magnetic resonance images. The pixel tracking process starts from the end-diastolic frame of the heart cycle using the available manually segmented images to predict the end-systolic segmentation mask. The superpixels approach is used to divide the raw images into smaller cells and in each time frame, new labels are assigned to the image cells which leads to tracking the movement of the heart wall elements through different frames. The tracked masks at the end of systole are compared with the already available manually segmented masks and dice scores are found to be between 0.81 to 0.84. Considering the fact that the proposed method does not necessarily require a training dataset, it could be an attractive alternative approach to deep learning segmentation methods in scenarios where training data are limited. Here, you can see an example result which is reproducible using the presented code: 

![myfile](Final.gif)

## How it workes?
In this method, we initially extract the superpixels cells of the raw image. Then by overlaying the segmentation mask from the previous frame on top of the superpixels cells of the current frame, we decide that each of the cells belongs to which label. To assign a uniform label value to each of the current frame cells, the most repeated label value of the previous mask in each of the cells is calculated. This basically means that if the majority of the cell is occupied by a label, we assign that value to the whole cell. As far as spatial changes from one frame to another are not larger than the average size of the cells, the method is promising to work. 

![myfile](Images/Slide-1.png)



