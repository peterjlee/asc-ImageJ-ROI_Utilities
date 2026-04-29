/*  Sort_ROI_set_by_Proximity_to_Current_ROI_set_v231130.ijm
	v231130: 1st version  Peter J. Lee Applied Superconductivity Center FSU NHMFL
	v231207:	Updated IJ.pad to String.pad.
	v240104:	Better auto-naming.
 */
macro "Sort ROI set by Proximity to Current ROIset" {
	macroL = "Sort_ROI_set_by_Proximity_to_Current_ROI_set_v240104.ijm";
	if (nImages==0) exit("An open image is required \(for Feret point determination\)"); /* Roi.getCoordinates and Roi.getBounds have the same problem = although it seems unnecessary */
	roisRefN = roiManager("count");
	fS = File.separator;
	refSaveDir = getDir("file");
	if (roisRefN==0){
		roiPath = File.openDialog("Select ROI set to open for reference positions");
		if (File.exists(roiPath)){
			if (resetROIS) roiManager("reset");
			roiManager("Open", roiPath);
		}
		if (roisRefN==0) exit("Failed to load reference ROI set");
	}
	else {
		refsOK = getBoolean("The current ROI set will be used for the reference order; is that OK?");
		if (!refsOK){
			roiRefsPath = File.openDialog("Select an ROI set to use for as the reference for ROI order");
			if (File.exists(roiRefsPath)){
				roiManager("reset");
				roiManager("Open", roiRefsPath);
				refSaveDir = File.getDirectory(roiRefsPath);
			}
			else exit("Reference ROI set not found");
		}
		else {
			saveRef = getBoolean("Do you want to save the current \(reference\) ROI set before it gets replaced?");
			if (saveRef) {
				Dialog.create("Reference ROI set save location: " + macroL);
					Dialog.addDirectory("Output directory:", refSaveDir);
					Dialog.addString("ROI set filename", File.nameWithoutExtension, 50);
				Dialog.show;
					roiSaveDir = Dialog.getString();
					if (!endsWith(roiSavePath, fS)) refSaveDir += fS;
					refFilename = Dialog.getString();
				roiManager("save", refSaveDir + refFilename);
			}
		}
	}
	refCFXs = newArray(roisRefN);
	refCFYs = newArray(roisRefN);
	for (i=0; i<roisRefN; i++){
		roiManager("select", i);
		Roi.getFeretPoints(xPoints, yPoints);
		Array.getStatistics(xPoints, null, null, refCFXs[i], null);
		Array.getStatistics(yPoints, null, null, refCFYs[i], null);
	}
	roiTargetPath = File.openDialog("Select ROI set to sort by distance \(current set will be replaced\)");
	if (File.exists(roiTargetPath)){
		roiManager("reset");
		roiManager("Open", roiTargetPath);
	}
	else exit("Target set not found");
	roisTargetN = roiManager("count");
	if (roisTargetN!=roisRefN) exit("ROI set mismatch, there are " + roisRefN + " reference ROIs and " + roisTargetN + " target ROIs");
	targetCFXs = newArray(roisTargetN);
	targetCFYs = newArray(roisTargetN);
	for (i=0; i<roisRefN; i++){
		roiManager("select", i);
		Roi.getFeretPoints(xPoints, yPoints);
		Array.getStatistics(xPoints, null, null, targetCFXs[i], null);
		Array.getStatistics(yPoints, null, null, targetCFYs[i], null);
	}
	oldNames =newArray("");
	for (i=0; i<roisTargetN; i++){
		for (j=0, minDist = 10E10; j<roisRefN; j++){
			distSq = pow(refCFXs[j] -  targetCFXs[i], 2) + pow(refCFYs[j] -  targetCFYs[i], 2);
			if (distSq < minDist){
				minDist = distSq;
				jRefMin = j;
			}
		}
		roiManager("select", i);
		oldNames[jRefMin] = Roi.getName();
		roiManager("Rename", String.pad(jRefMin + 1, 4)); 
	}
	roiManager("Deselect");
	roiManager("Sort");
	roiManager("Show None");
	roiManager("Show All");
	Dialog.create("Final options: " + macroL);
		Dialog.addCheckbox("Restore original names of sorted ROIs?", false);
		Dialog.addCheckbox("Save new sorted set?", true);
		Dialog.addDirectory("Output directory:", refSaveDir);
		Dialog.addString("ROI set filename \(.zip will be appended\)", File.nameWithoutExtension + "-sorted", 50);
		if (isOpen("Results")) Dialog.addCheckbox("Close previous results?", true);
		if (nImages>0) Dialog.addCheckbox("Measure new results?", true);
	Dialog.show;
		if (Dialog.getCheckbox()){
			for (i=0; i<roisTargetN; i++){
				roiManager("select", i);
				roiManager("Rename", oldNames[i]);
			}
			roiManager("Deselect");
		}
		saveNew = Dialog.getCheckbox();
		roiSavePath = Dialog.getString();
		if (!endsWith(roiSavePath, fS)) roiSavePath += fS;
		roiSavePath += Dialog.getString();
		if (!endsWith(roiSavePath, ".zip")) roiSavePath += ".zip";
		if (saveNew) roiManager("save", roiSavePath);
		if (isOpen("Results")){
			if (Dialog.getCheckbox()) {
				selectWindow("Results");
				run("Close");
			}
		}
		if (nImages>0){
			if (Dialog.getCheckbox()){
				roiManager("Deselect");
				roiManager("Measure");
			} 
		}
		/* End of final dialog */
	run("Select None");
	showStatus(macroL + " complete", "flash green");
	/* End of Sort ROI set by Proximity to Current ROIset macro */
}