// crop_To_Roi_mitograph.ijm
// ImageJ/Fiji macro by Theresa Swayne, Columbia University, 2017
// Input: An image or stack, and a set of ROIs in the ROI manager 
// Output: The following items are saved in the same folder as the input image: 
// -- A cropped image or stack for each ROI. 
// 		Output images are numbered from 1 to the number of ROIs, 
//		and are saved in the same folder as the source image.
//		Non-rectangular ROIs are cropped to their bounding box, but the area outside the ROI is cleared to black
// -- An ROI set (.zip file) containing the ROIs.
// -- A snapshot of the ROI locations on the composite image, at the current timepoint, using the current display settings.
// Usage: Open an image. 
//		For each area you want to crop out, draw an ROI and press T to add to the ROI Manager.
//		Then run the macro.
// TODO: changes from contractile ring crop macro: 
// asks for which channel is mito and saves only that one
// implements the above using script parameters where possible

// SETUP

path = getDirectory("image");
id = getImageID();
print("original image id",id)
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

setBackgroundColor(0, 0, 0); // set background to black for proper clearing outside 

// save ROIs to show location of each cell
roiManager("save",path+basename+"_ROIs.zip");

// save a snapshot
if (is("composite")) {
	Stack.setDisplayMode("composite"); // this command raises error if image is not composite
	run("Stack to RGB", "keep");
}
else {
	run("Select None");
	run("Duplicate...", "title=copy duplicate"); // for single-channel non-RGB images; Flatten doesn't create new window
}

rgbID = getImageID();
selectImage(rgbID);
roiManager("Show All with labels");
run("Flatten", "stack");
flatID = getImageID();
selectImage(flatID);
saveAs("tiff", path+basename+"_ROIlocs.tif");

// clean up

if (isOpen(flatID)) {
	selectImage(flatID);
	close();
}

if (isOpen(rgbID)) {
	selectImage(rgbID);
	close();
}

// make sure nothing selected to begin with

selectImage(id);
roiManager("Deselect");
run("Select None");


numROIs = roiManager("count");
for(roiIndex=0; roiIndex < numROIs; roiIndex++) // loop through ROIs
	{ 
	selectImage(id);
	roiNum = roiIndex + 1; // image names starts with 1 like the ROI labels
	cropName = basename+"_crop"+roiNum;
	roiManager("Select", roiIndex);  // ROI indices start with 0
	run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
	selectWindow(cropName);
	run("Clear Outside","stack"); // this works because the roi is still active on the cropped image
	run("Select None");// clears the selection that is otherwise saved with the image
	saveAs("tiff", path+getTitle);
	close();
	}	
run("Select None");

print("Finished.");
close();
