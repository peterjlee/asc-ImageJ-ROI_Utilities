macro "Export all ROIs as Image Files" {
	/*	Changes after v240905:		
		v260427	1st version
		v260428 Adds common size option.
	*/
	requires("1.53d"); /* Uses RoiManager.multiCrop for ROI export and compact montage creation */
	macroL = "Export_all_ROIs+_as_ImageFiles_v260427.ijm";
	if (isOpen("ROI Manager")) nROIs = roiManager("count");
	else exit("This macros needs ROIs");
	if (nImages == 0) exit("Sorry this macro needs an image to save, goodbye");
	diagnostics = false; /* this can be activated for debugging */
	fS = File.separator;
	recentDir = getDir("file");
	activeDir = getDirectory("image"); /* Returns the path to the directory that the active image was loaded from */
	currentDir = getInfo("image.directory"); /* Returns the directory that the current image was loaded from, or an empty string if the directory is not available */
	openedDir = File.directory; /* The directory path of the last file opened using a file open dialog, a file save dialog, drag and drop, open(path) or runMacro(path). */
	workingDir = getDir("cwd");
	saveDirs = newArray();
	iJPath = getDirectory("imagej");
	if (indexOfArrayThatContains(saveDirs, activeDir, -1) < 0) saveDirs = Array.concat(saveDirs, "Active Directory: " + activeDir);
	if (indexOfArrayThatContains(saveDirs, currentDir, -1) < 0) saveDirs = Array.concat(saveDirs, "Current Directory: " + currentDir);
	if (indexOfArrayThatContains(saveDirs, openedDir, -1) < 0) saveDirs = Array.concat(saveDirs, "Last Opened Directory: " + openedDir);
	if (indexOfArrayThatContains(saveDirs, recentDir, -1) < 0) saveDirs = Array.concat(saveDirs, "Recent Directory: " + recentDir);
	if (indexOfArrayThatContains(saveDirs, workingDir, -1) < 0) saveDirs = Array.concat(saveDirs, "Working Directory: " + workingDir);
	iJPathI = indexOfArray(saveDirs, iJPathI, -1);
	if (iJPathI >= 0) saveDirs = Array.deleteIndex(saveDirs, iJPathI);
	for (i = 0, maxPath = 0; i < saveDirs.length; i++) maxPath = maxOf(maxPath, saveDirs[i].length);
	saveDir = workingDir; /* Default export directlry */
	fileName = unCleanLabel(stripKnownExtensionFromString(getTitle));
	getDimensions(imageWidth, imageHeight, channels, slices, frames);
	getVoxelSize(pixelWidth, pixelHeight, pixelDepth, unit);
	sWidth = screenWidth();
	sHeight = screenHeight();
	nOverlays = Overlay.size;
	roiWidths = newArray(nROIs);
	roiHeights = newArray(nROIs);
	for (i = 0, maxWidth = 0, maxHeight = 0; i < nROIs; i++){
		roiManager("Select", i);
		getSelectionBounds(x, y, roiWidths[i], roiHeights[i]);
	}
	Array.getStatistics(roiWidths, roiWidthsMin, roiWidthsMax, roiWidthsMean, null);
	Array.getStatistics(roiHeights, roiHeightsMin, roiHeightsMax, roiHeightsMean, null);
	/* ASC message theme */
	infoColor = "#006db0"; /* Honolulu blue */
	instructionColor = "#798541"; /* green_dark_modern (121,133,65) AKA Wasabi */
	infoWarningColor = "#ff69b4"; /* pink_modern AKA hot pink */
	infoFontSize = 12;
	Dialog.create("ROI save options \(" + macroL + "\)");
		roiFileTypes = newArray("tiff", "png", "jpg");
		Dialog.addRadioButtonGroup("Output file type \(TIFF will be used for stacks\):", roiFileTypes, 1, 3, roiFileTypes[0]);
		Dialog.addMessage("ROI widths: " + roiWidthsMin + " - " + roiWidthsMax + " Mean: " + roiWidthsMean + 
				", ROI Heights: " + roiHeightsMin + " - " + roiHeightsMax + " Mean: " + roiHeightsMean);
		Dialog.addNumber("Expand region around all ROIs by", 0, 0, 3, "pixels");
		Dialog.addCheckbox("Alternatively expand ROIs region to the same width and height:", false);
		Dialog.addNumber(" . . . . common width \(minimum common width is " + roiWidthsMax + "\) of ", roiWidthsMax, 0, 3, "pixels");
		Dialog.addNumber(" . . . . common height \(minimum common height is " + roiHeightsMax + "\) of ", roiHeightsMax, 0, 3, "pixels");
		Dialog.setInsets(0, 20, 0);
		Dialog.addCheckboxGroup(1, 2, newArray("Also create stack", "Save ROI list"), newArray(true, false));
		Dialog.addString("File name prefixes \(no suffix\)", fileName, fileName.length + 5);
		lastSavedROIPath = call("ij.Prefs.get", "asc.lastsaved.roi.path", "not found");
		if (lastSavedROIPath != "not found" && indexOf(lastSavedROIPath, iJPath) < 0) saveDirs = Array.concat("Last ROIs Saved: " + lastSavedROIPath, saveDirs);
		if (saveDirs.length > 0) {
			Dialog.addRadioButtonGroup("Set output directory or... :", saveDirs, saveDirs.length, 1, saveDirs[0]);
			Dialog.addDirectory("or...Specify directory \(leave blank if using selection above\)", "");
		} else Dialog.addDirectory("Enter or choose directory \(leave blank if using selection above\)", "");
		Dialog.addString("Create sub-directory \(leave blank if not desired\):", "", minOf(sWidth - 50, lengthOf(fileName) + 10));
		Dialog.setInsets(20, 40, 0);
		Dialog.addCheckbox("Montage: Create rectangular montage from saved ROIs------------------------------", false);
		Dialog.addNumber("Montage: There are " + nROIs + " ROIs; how many rows?", round(sqrt(nROIs)), 0, 5, "");
		Dialog.addNumber("Montage: Scale factor", 1, 2, 5, "pixels");
		Dialog.addNumber("Montage: ROI border widths", 1, 0, 5, "pixels");
		oForegroundColor = Color.foreground;
		borderColors = newArray("black", "white", "gray", "darkGray", "lightGray");
		if (bitDepth() == 24){
			borderColors = Array.concat(borderColors, "blue", "cyan","gray", "green", "lightGray", "magenta", "orange", "pink", "red", "yellow");
			if (indexOfArray(borderColors, oForegroundColor, -1) < 0) borderColors = Array.concat(oForegroundColor, borderColors);
			Dialog.addRadioButtonGroup("Montage: Border color", borderColors, 2, Math.ceil(borderColors.length /2), oForegroundColor);
		} else {
			if (indexOfArray(borderColors, oForegroundColor, -1) < 0) borderColors = Array.concat(oForegroundColor, borderColors);
			Dialog.addRadioButtonGroup("Montage: Border color", borderColors, 1, borderColors.length, oForegroundColor);
		}
	Dialog.show;
		roiTypeChoice = Dialog.getRadioButton();
		expandN = Dialog.getNumber();
		commonSize = Dialog.getCheckbox();
		maxROIWidth = Dialog.getNumber();
		maxROIHeight = Dialog.getNumber();
		alsoStack = Dialog.getCheckbox();
		saveROIList = Dialog.getCheckbox();
		fileNamePrefix = unCleanLabel(Dialog.getString());
		if (saveDirs.length > 0) dirChoice = Dialog.getRadioButton();
		selDir = Dialog.getString();
		if (selDir != "") saveDir = selDir;
		else if (saveDirs.length < 1) exit("No output directory selected");
		else if (startsWith(dirChoice, "Active")) saveDir = activeDir;
		else if (startsWith(dirChoice, "Current")) saveDir = currentDir;
		else if (startsWith(dirChoice, "Last Opened")) saveDir = openedDir;
		else if (startsWith(dirChoice, "Recent")) saveDir = recentDir;
		else if (startsWith(dirChoice, "Working")) saveDir = workingDir;
		else if (startsWith(dirChoice, "Last ROIs Saved")) saveDir = lastSavedROIPath;
		if (!endsWith(saveDir, fS)) saveDir += fS;
		if (!File.isDirectory(saveDir)) {
			if (File.exists(saveDir)) exit("Selected directory is a file not a directory");
			else File.makeDirectory(saveDir);
		}
		subDir = Dialog.getString();
		makeMontage = Dialog.getCheckbox();
		gridRows = Dialog.getNumber();
		gridCols = Math.ceil(nROIs / gridRows);
		scaleFactor = Dialog.getNumber();
		borderThickness = Dialog.getNumber();
		borderColor = Dialog.getRadioButton();
	if (!diagnostics) setBatchMode("true");
	if (makeMontage) alsoStack = true;
	/* end main options menu */
	roiOptions = "save ";
	if (subDir != "") {
		if (!endsWith(saveDir, fS)) saveDir += fS;
		saveDir += subDir + fS;
	}
	if (!File.isDirectory(saveDir)) {
		if (File.exists(saveDir)) exit("Selected directory is a file not a directory");
		else File.makeDirectory(saveDir);
	}
	call("ij.Prefs.set", "asc.lastsaved.roi.path", saveDir);
	if (roiTypeChoice != "tiff") roiOptions += roiTypeChoice;
	if (alsoStack) roiOptions += " show";
	roiManager("Deselect");
	if (saveROIList) roiManager("Save", saveDir + fileNamePrefix + "_RoiSet.zip");
	if (expandN > 0 || commonSize) {
		stackList = "";
		for (i = 0; i < nROIs; i++){
			showProgress(i, nROIs);
			roiManager("Select", i);
			if (expandN > 0) run("Enlarge...", "enlarge=" + expandN + " pixel");
			else {
				getSelectionBounds(startX, startY, selWidth, selHeight);
				dW = maxROIWidth - selWidth;
				startX = maxOf(0, startX - dW /2);
				dH = maxROIHeight - selHeight;
				startY = maxOf(0, startY - dH /2);
				makeRectangle(startX, startY, maxROIWidth,  maxROIHeight);
			}
			run("Duplicate...", "title=temp");
			run("Select None");
			filePath = saveDir + RoiManager.getName(i) + "." + substring(roiTypeChoice, 0, 3);
			saveAs(roiTypeChoice, filePath);
			stackList += filePath + "\n";
			close;
			roiManager("Deselect");
		}
		if (alsoStack){
			stackListPath = saveDir + RoiManager.getName(0) + "-" + RoiManager.getName(nROIs - 1) + ".txt";
			File.saveString(stackList, stackListPath);
			wait(100);
			run("Stack From List...", "open=[" + stackListPath + "]");
			oROICropStackID = getImageID();
			roiStackPath = pathLengthCheck(saveDir + fileNamePrefix + "_ROI-Stack", 128);
			roiStackPath = pathOverwriteCheck(roiStackPath);
			saveAs("Tiff", roiStackPath); /* Use IJ tiff to retain scale etc. */
		}
		roiManager("Deselect");
		IJ.log("ROIs saved in " + saveDir);
	}
	else {
		RoiManager.multiCrop(saveDir, roiOptions);
		if (alsoStack){
			/* A stack named "CROPPED_ROI Manager" will now be available containing all the ROIs */
			if (isOpen("CROPPED_ROI Manager"))	selectWindow("CROPPED_ROI Manager");
			else exit("RoiManager.multiCrop did not create stack as expected, currrent image is " + getTitle());
			getVoxelSize(pixelWidthN, pixelHeightN, pixelDepthN, unitN);
			/* No scaling operations should be applied to the ROI saves */
			if (unitN == "pixels") setVoxelSize(pixelWidth, pixelHeight, pixelDepth, unit);
			roiStackPath = pathLengthCheck(saveDir + fileNamePrefix + "_ROI-Stack", 128);
			roiStackPath = pathOverwriteCheck(roiStackPath);
			saveAs("Tiff", roiStackPath);
			oROICropStackID = getImageID();
		}
	}
	if (makeMontage) {
		selectImage(oROICropStackID);
		Color.setForeground(borderColor);
		run("Make Montage...", "columns=&gridCols rows=&gridRows scale=&scaleFactor border=&borderThickness use");
		Color.setForeground(oForegroundColor);
		montageTitle = fileNamePrefix + "_" + gridCols + "x" + gridRows + "_Montage";
		rename(montageTitle);
		montagePath = pathLengthCheck(saveDir + montageTitle, 128);
		montagePath = pathOverwriteCheck(montagePath);
		saveAs(roiTypeChoice, montagePath); 
	}
	if (makeMontage && !alsoStack) {
		selectImage(oROICropStackID);
		close();
	}
	IJ.log("ROIs saved in " + saveDir);
	showStatus("ROI export finished");
	if (Overlay.size != 0) Overlay.show;
	setBatchMode("exit and display");
	beep();	wait(100);	beep();	wait(300);	beep();
	call("java.lang.System.gc");
	showStatus("ROIs exported", "flash green");
	/* End of Export all ROIs+ as Image Files macro */
}
/*
	( 8(|))  ( 8(|))  ( 8(|))  ASC Functions  @@@@@:-)  @@@@@:-)  @@@@@:-)
*/
	function indexOfArray(array, value, default) {
		/* v190423 Adds "default" parameter (use -1 for backwards compatibility). Returns only first found value
			v230902 Limits default value to array size */
		index = minOf(lengthOf(array) - 1, default);
		for (i = 0; i < lengthOf(array); i++) {
			if (array[i] == value) {
				index = i;
				i = parseFloat("Infinity");
			}
		}
		return index;
	}
	function indexOfArrayThatContains(array, value, default) {
		/* Like indexOfArray but partial matches possible
			v190423 Only first match returned, v220801 adds default.
			v230902 Limits default value to array size */
		indexFound = minOf(lengthOf(array) - 1, default);
		for (i = 0; i < lengthOf(array); i++) {
			if (indexOf(array[i], value) >= 0) {
				indexFound = i;
				i = parseFloat("Infinity");
			}
		}
		return indexFound;
	}
	function pathLengthCheck(path, maxLength){
		/* v230504: 1st version */
		functionL = "pathLengthCheck_v240829";
		pathLength = lengthOf(path);
		if (pathLength>maxLength){
			pathLengthMessage = "Path length is " + pathLength-maxLength + " characters longer than chosen maximum \(" + maxLength + "\), try shortening the path:";
			fS = File.separator;
			dirPathEnd = lastIndexOf(path, fS)+1;
			Dialog.create("Shorten path length \(function: " + functionL + "\)");
				Dialog.addMessage(pathLengthMessage);
				if (dirPathEnd>0){
					dirPath = substring(path, 0, dirPathEnd);
					fileName = substring(path, dirPathEnd);
					Dialog.addDirectory("Directory path:", dirPath);
				}
				else fileName = path;
				Dialog.addString("File name:", fileName, fileName.length);
			Dialog.show();
				if (dirPathEnd>0)	path = Dialog.getString() + Dialog.getString();
				else path = Dialog.getString();
		}
		return path;
	}
	function pathOverwriteCheck(path){
		/* v220615: 1st version reworked 061622
			v230811: Fixed to avoid unnecessary loop
			v240118: Fixed path not being updated
			*/
		if (File.exists(path)) saveFlag = false;
		else saveFlag = true;
		while(saveFlag==false){
			newPath = getString("Overwite existing file \(leave\) or rename:", path);
			if (newPath==path || !File.exists(newPath)) saveFlag = true;
			path = newPath;
		}
		return path;
	}
	function stripKnownExtensionFromString(string){
		/*	Note: Do not use on path as it may change the directory names
		v210924: Tries to make sure string stays as string.	v211014: Adds some additional cleanup.	v211025: fixes multiple 'known's issue.	v211101: Added ".Ext_" removal.
		v211104: Restricts cleanup to end of string to reduce risk of corrupting path.	v211112: Tries to fix trapped extension before channel listing. Adds xlsx extension.
		v220615: Tries to fix the fix for the trapped extensions ...	v230504: Protects directory path if included in string. Only removes doubled spaces and lines.
		v230505: Unwanted dupes replaced by unusefulCombos.	v230607: Quick fix for infinite loop on one of while statements.
		v230614: Added AVI.	v230905: Better fix for infinite loop. v230914: Added BMP and "_transp" and rearranged
		*/
		fS = File.separator;
		string = "" + string;
		protectedPathEnd = lastIndexOf(string, fS) + 1;
		if (protectedPathEnd>0){
			protectedPath = substring(string, 0, protectedPathEnd);
			string = substring(string, protectedPathEnd);
		}
		unusefulCombos = newArray("-", "_", " ");
		for (i=0; i<lengthOf(unusefulCombos); i++){
			for (j=0; j<lengthOf(unusefulCombos); j++){
				combo = unusefulCombos[i] + unusefulCombos[j];
				while (indexOf(string, combo)>=0) string = replace(string, combo, unusefulCombos[i]);
			}
		}
		if (lastIndexOf(string, ".")>0 || lastIndexOf(string, "_lzw")>0){
			knownExts = newArray(".avi", ".csv", ".bmp", ".dsx", ".gif", ".jpg", ".jpeg", ".jp2", ".png", ".tif", ".txt", ".xlsx");
			knownExts = Array.concat(knownExts, knownExts, "_transp", "_lzw");
			kEL = knownExts.length;
			for (i=0; i<kEL/2; i++) knownExts[i] = toUpperCase(knownExts[i]);
			chanLabels = newArray(" \(red\)", " \(green\)", " \(blue\)", "\(red\)", "\(green\)", "\(blue\)");
			for (i=0, k=0; i<kEL; i++){
				for (j=0; j<chanLabels.length; j++){ /* Looking for channel-label-trapped extensions */
					iChanLabels = lastIndexOf(string, chanLabels[j])-1;
					if (iChanLabels>0){
						preChan = substring(string, 0, iChanLabels);
						postChan = substring(string, iChanLabels);
						while (indexOf(preChan, knownExts[i])>0){
							preChan = replace(preChan, knownExts[i], "");
							string =  preChan + postChan;
						}
					}
				}
				while (endsWith(string, knownExts[i])) string = "" + substring(string, 0, lastIndexOf(string, knownExts[i]));
			}
		}
		unwantedSuffixes = newArray(" ", "_", "-");
		for (i=0; i<unwantedSuffixes.length; i++){
			while (endsWith(string, unwantedSuffixes[i])) string = substring(string, 0, string.length-lengthOf(unwantedSuffixes[i])); /* cleanup previous suffix */
		}
		if (protectedPathEnd>0){
			if(!endsWith(protectedPath, fS)) protectedPath += fS;
			string = protectedPath + string;
		}
		return string;
	}
	function unCleanLabel(string){
	/* v161104 This function replaces special characters with standard characters for file system compatible filenames.
	+ 041117b to remove spaces as well.
	+ v220126 added getInfo("micrometer.abbreviation").
	+ v220128 add loops that allow removal of multiple duplication.
	+ v220131 fixed so that suffix cleanup works even if extensions are included.
	+ v220616 Minor index range fix that does not seem to have an impact if macro is working as planned. v220715 added 8-bit to unwanted dupes. v220812 minor changes to micron and Ångström handling
	+ v231005 Replaced superscript abbreviations that did not work.
	+ v240124 Replace _+_ with +.
	*/
		/* Remove bad characters */
		string = string.replace(fromCharCode(178), "sup2"); /* superscript 2 */
		string = string.replace(fromCharCode(179), "sup3"); /* superscript 3 UTF-16 (decimal) */
		string = string.replace(fromCharCode(0xFE63) + fromCharCode(185), "sup-1"); /* Small hyphen substituted for superscript minus as 0x207B does not display in table */
		string = string.replace(fromCharCode(0xFE63) + fromCharCode(178), "sup-2"); /* Small hyphen substituted for superscript minus as 0x207B does not display in table */
		string = string.replace(fromCharCode(181) + "m", "um"); /* micron units */
		string = string.replace(getInfo("micrometer.abbreviation"), "um"); /* micron units */
		string = string.replace(fromCharCode(197), "Angstrom"); /* Ångström unit symbol */
		string = string.replace(fromCharCode(0x212B), "Angstrom"); /* the other Ångström unit symbol */
		string = string.replace(fromCharCode(0x2009) + fromCharCode(0x00B0), "deg"); /* replace thin spaces degrees combination */
		string = string.replace(fromCharCode(0x2009), "_"); /* Replace thin spaces  */
		string = string.replace("%", "pc"); /* % causes issues with html listing */
		string = string.replace(" ", "_"); /* Replace spaces - these can be a problem with image combination */
		/* Remove duplicate strings */
		unwantedDupes = newArray("8bit", "8-bit", "lzw");
		for (i=0; i<lengthOf(unwantedDupes); i++){
			iLast = lastIndexOf(string, unwantedDupes[i]);
			iFirst = indexOf(string, unwantedDupes[i]);
			if (iFirst!=iLast){
				string = string.substring(0, iFirst) + string.substring(iFirst + lengthOf(unwantedDupes[i]));
				i = -1; /* check again */
			}
		}
		unwantedDbls = newArray("_-", "-_", "__", "--", "\\+\\+");
		for (i=0; i<lengthOf(unwantedDbls); i++){
			iFirst = indexOf(string, unwantedDbls[i]);
			if (iFirst>=0){
				string = string.substring(0, iFirst) + string.substring(string, iFirst + lengthOf(unwantedDbls[i]) / 2);
				i = -1; /* check again */
			}
		}
		string = string.replace("_\\+", "\\+"); /* Clean up autofilenames */
		string = string.replace("\\+_", "\\+"); /* Clean up autofilenames */
		/* cleanup suffixes */
		unwantedSuffixes = newArray(" ", "_", "-", "\\+"); /* things you don't wasn't to end a filename with */
		extStart = lastIndexOf(string, ".");
		sL = lengthOf(string);
		if (sL-extStart<=4 && extStart>0) extIncl = true;
		else extIncl = false;
		if (extIncl){
			preString = substring(string, 0, extStart);
			extString = substring(string, extStart);
		}
		else {
			preString = string;
			extString = "";
		}
		for (i=0; i<lengthOf(unwantedSuffixes); i++){
			sL = lengthOf(preString);
			if (endsWith(preString, unwantedSuffixes[i])){
				preString = substring(preString, 0, sL-lengthOf(unwantedSuffixes[i])); /* cleanup previous suffix */
				i=-1; /* check one more time */
			}
		}
		if (!endsWith(preString, "_lzw") && !endsWith(preString, "_lzw.")) preString = replace(preString, "_lzw", ""); /* Only want to keep this if it is at the end */
		string = preString + extString;
		/* End of suffix cleanup */
		return string;
	}