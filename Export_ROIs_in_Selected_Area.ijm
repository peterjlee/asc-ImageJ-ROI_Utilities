/* Export ROIs in selected area
	v231012:	1st Version  Peter J. Lee, Applied Superconductivity Center
	v231013:	Added option to export ROI list as csv file.
	v231129:	Corrected exportZip to exportZIP. Fixed file path. b: Saves bounding box for future use. c: replaced nROIs with roisN for consistency with ASC naming format. F1: updated function unCleanLabel.
 */
macro "Selected Area ROI Exporter" {
	macroL = "Export_ROIs_in_Selected_Area_v231129c-f1.ijm";
	macroV = substring(macroL,lastIndexOf(macroL,"_v") + 2,maxOf(lastIndexOf(macroL,"."),lastIndexOf(macroL,"_v") + 8));
	requires("1.53g"); /* Uses expandable arrays */
	selType = selectionType;
	lastBounds = call("ij.Prefs.get", "asc.roi.manual.bounds","");
	if (selType<0 || selType>4){
		usePreviousBounds = false;
		if (lastBounds!=""){
			previousBounds = split(lastBounds,",");
			if (lengthOf(previousBounds)==4) usePreviousBounds = getBoolean("There is no selection, do you want to use the previously saved bounds?", true);
		}
		if (usePreviousBounds)
			  makeRectangle(parseInt(previousBounds[0]), parseInt(previousBounds[1]), parseInt(previousBounds[2]), parseInt(previousBounds[3]));
	}
	if (selType<0 || selType>4){
		msg = "Draw a bounding box around the ROIs to be selected";
		waitForUser("Please select the ROIs", msg);
	}
	if (selType>=0 && selType<4){
		getSelectionBounds(selPosStartX, selPosStartY, originalSelEWidth, originalSelEHeight);
		call("ij.Prefs.set", "asc.roi.manual.bounds","" + selPosStartX + "," + selPosStartY + "," + originalSelEWidth + "," + originalSelEHeight);
	}
	/*  smallest rectangle that can completely contain the current selection */
	roisN = roiManager("count");
	if (roisN>1) roiManager("deselect");
	else exit("Need at least 2 ROIs for this macro to be useful");
	ascPrefsKey = "asc.exportROIs.Prefs.";
	orID = getImageID(); /* get id of image and title */
	t = getTitle();
	tPath = getDirectory("image");
	if (tPath=="") tPath = File.directory;
	if (indexOf(tPath, "AutoRun")>=0) tPath = "";
	tN = stripKnownExtensionFromString(unCleanLabel(t)); /* File.nameWithoutExtension is specific to last opened file, also remove special characters that might cause issues saving file */
	if (lengthOf(tN)>43) tNL = substring(tN,0,21) + "..." + substring(tN, lengthOf(tN)-21);
	else tNL = tN;
	fS = File.separator;
	subset = false;
	subsetROIs = "";
	setBatchMode(true);
	/* finds sub-elements inside and at selection */
	roiManager("select", 0);
	roiStart = Roi.getName;
	roiManager("Deselect");
	run("Restore Selection");
	roiManager("Add");
	roiManager("select", 0);
	roiStart2 = Roi.getName;
	if (roiStart==roiStart2) roiManager("select", roisN);
	else roiManager("select", 0);
	iTempROI = roiManager("index");
	roiManager("Rename", "Temp_SelectionROI");
	for (i=0, nSels=0; i<roisN + 1; i++){
		if (i!=iTempROI){
			// roiManager("deselect");
			roiManager("select", i);
			roiSize = getValue("selection.size");
			roiManager("Select", newArray(i, iTempROI));
			roiManager("AND");
			if (getValue("selection.size")==roiSize){
				subsetROIs += "" + i+1 + ",";
				nSels++;
			}
		}
	}
	roiManager("deselect");
	RoiManager.selectByName("Temp_SelectionROI");
	if (roiManager("index")==iTempROI)
		roiManager("delete");
	roiManager("deselect");
	if (endsWith(subsetROIs,","))
		subsetROIs = substring(subsetROIs, 0, lengthOf(subsetROIs)-1);
	setBatchMode(false);
	infoColor = "#006db0"; /* Honolulu blue */
	instructionColor = "#798541"; /* green_dark_modern (121,133,65) AKA Wasabi */
	infoWarningColor = "#ff69b4"; /* pink_modern AKA hot pink */
	infoFontSize = 12;
	/* Create initial dialog prompt to determine parameters */
	Dialog.create("Parameter Selection: " + macroL);
		/* if called from the BAR menu there will be no macro.filepath so the following checks for that */
		startInfo = "Filename: " + tNL + "\nImage has " + roisN;
		if (tPath.length>60) startInfo += "\nDirectory: " + substring(tPath,0,tPath.length / 2) + "...\n       ..." + substring(tPath, tPath.length / 2);
		Dialog.setInsets(0,10,20);
		Dialog.addMessage(startInfo, infoFontSize+1.5, infoColor);
		Dialog.setInsets(0, 20, 0);
		Dialog.addDirectory("Output directory:",tPath);
		Dialog.setInsets(0, 20, 0);
		Dialog.addMessage("Exporting " + nSels + " ROIs \(list populated below from selected " + convertTypeToString(selType, true) + "\):_____________________", infoFontSize+1.5, infoColor);
		Dialog.addCheckbox("Export ROIs as zip file?", call("ij.Prefs.get", ascPrefsKey + "exportZIP", true));
		Dialog.setInsets(0, 20, 0);
		Dialog.addCheckbox("Export ROI list as csv file?", call("ij.Prefs.get", ascPrefsKey + "exportCSV", true));
		Dialog.setInsets(0, 20, 0);
		Dialog.addString("ROIs \(list separated by commas\)", subsetROIs, 40);
		Dialog.addNumber("Assign selected ROIs to this group number \(0 default\):", 0, 0, 2, "positive number");
	Dialog.show;
		tPath = Dialog.getString();
		if (!endsWith(tPath, fS)) tPath += fS;
		exportZIP = Dialog.getCheckbox();
		exportCSV = Dialog.getCheckbox();
		subsetROIs = Dialog.getString();
		groupN = parseInt(Dialog.getNumber());
	if (exportCSV || exportZIP) subset = true;
	if (subsetROIs=="")
		exit("subset not listed in Dialog");
	subsetArray = split(subsetROIs, ",,");
	subsetArray = Array.sort(subsetArray);
	items = lengthOf(subsetArray);
	if (items<1)
		exit("Unable to extract array from this list: " + subsetROIs);
	IJ.log(items + " selected ROIs:");
	Array.print(subsetArray);
	iROIs = newArray;
	for (i=0; i<items; i++) iROIs[i] = parseInt(subsetArray[i])-1;
	call("ij.Prefs.set", ascPrefsKey + "subset", subset);
	roiManager("select", iROIs);
	RoiManager.setGroup(groupN);
	if (subset){
		timeStamp = getDateTimeCode();
		timeStamp = substring(timeStamp, 0, lastIndexOf(timeStamp, "m"));
		if (exportZIP){
			roiZIPPath = tPath + tNL + "_" + items + "_" + timeStamp + "_" + "SelectedROIs.zip";
			roiManager("save selected", roiZIPPath);
		}
		if (exportCSV){
			roiListPath = tPath + tNL + "_" + items + "_" + timeStamp + "_" + "SelectedROIs.csv";
			File.saveString(subsetROIs, roiListPath);
		}
	}
	roiManager("Deselect");	
	setBatchMode("exit & display");
	showStatus(macroL + " macro finished");
	beep(); wait(300); beep(); wait(300); beep();
	/* End of Export ROIs in Selected Area */
}
	/*
		   ( 8(|)	( 8(|)	Functions	@@@@@:-)	@@@@@:-)
   */
	function convertTypeToString(type, lowercase) {
	/*	v230221 uses array  v231013 added "lowercase" boolean flag and added point type to expand use to selections, and expanded some strings to reflect selection descriptions */
		if(type>10 || type<0) exit("Sorry, " + type + " must be from 0 to 10");
		shapeTypes = newArray("Rectangle", "Oval", "Polygon", "Freehand", "Traced", "Straight Line", "Segmented PolyLine", "Freehand Line", "Angle", "Composite", "Point");
		if (lowercase) return toLowerCase(shapeTypes[parseInt(type)]);
		else return shapeTypes[parseInt(type)];
	}
  	function getDateTimeCode() {
		/* v211014 based on getDateCode v170823 */
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		month = month + 1; /* Month starts at zero, presumably to be used in array */
		if(month<10) monthStr = "0" + month;
		else monthStr = ""  + month;
		if (dayOfMonth<10) dayOfMonth = "0" + dayOfMonth;
		dateCodeUS = monthStr+dayOfMonth+substring(year,2)+"-"+hour+"h"+minute+"m";
		return dateCodeUS;
	}
	function stripKnownExtensionFromString(string) {
		/*	Note: Do not use on path as it may change the directory names
		v210924: Tries to make sure string stays as string.	v211014: Adds some additional cleanup.	v211025: fixes multiple 'known's issue.	v211101: Added ".Ext_" removal.
		v211104: Restricts cleanup to end of string to reduce risk of corrupting path.	v211112: Tries to fix trapped extension before channel listing. Adds xlsx extension.
		v220615: Tries to fix the fix for the trapped extensions ...	v230504: Protects directory path if included in string. Only removes doubled spaces and lines.
		v230505: Unwanted dupes replaced by unusefulCombos.	v230607: Quick fix for infinite loop on one of while statements.
		v230614: Added AVI.	v230905: Better fix for infinite loop. v230914: Added BMP and "_transp" and rearranged
		*/
		fS = File.separator;
		string = "" + string;
		protectedPathEnd = lastIndexOf(string,fS)+1;
		if (protectedPathEnd>0){
			protectedPath = substring(string,0,protectedPathEnd);
			string = substring(string,protectedPathEnd);
		}
		unusefulCombos = newArray("-", "_"," ");
		for (i=0; i<lengthOf(unusefulCombos); i++){
			for (j=0; j<lengthOf(unusefulCombos); j++){
				combo = unusefulCombos[i] + unusefulCombos[j];
				while (indexOf(string,combo)>=0) string = replace(string,combo,unusefulCombos[i]);
			}
		}
		if (lastIndexOf(string, ".")>0 || lastIndexOf(string, "_lzw")>0) {
			knownExts = newArray(".avi", ".csv", ".bmp", ".dsx", ".gif", ".jpg", ".jpeg", ".jp2", ".png", ".tif", ".txt", ".xlsx");
			knownExts = Array.concat(knownExts,knownExts,"_transp","_lzw");
			kEL = knownExts.length;
			for (i=0; i<kEL/2; i++) knownExts[i] = toUpperCase(knownExts[i]);
			chanLabels = newArray(" \(red\)"," \(green\)"," \(blue\)","\(red\)","\(green\)","\(blue\)");
			for (i=0,k=0; i<kEL; i++) {
				for (j=0; j<chanLabels.length; j++){ /* Looking for channel-label-trapped extensions */
					iChanLabels = lastIndexOf(string, chanLabels[j])-1;
					if (iChanLabels>0){
						preChan = substring(string,0,iChanLabels);
						postChan = substring(string,iChanLabels);
						while (indexOf(preChan,knownExts[i])>0){
							preChan = replace(preChan,knownExts[i],"");
							string =  preChan + postChan;
						}
					}
				}
				while (endsWith(string,knownExts[i])) string = "" + substring(string, 0, lastIndexOf(string, knownExts[i]));
			}
		}
		unwantedSuffixes = newArray(" ", "_","-");
		for (i=0; i<unwantedSuffixes.length; i++){
			while (endsWith(string,unwantedSuffixes[i])) string = substring(string,0,string.length-lengthOf(unwantedSuffixes[i])); /* cleanup previous suffix */
		}
		if (protectedPathEnd>0){
			if(!endsWith(protectedPath,fS)) protectedPath += fS;
			string = protectedPath + string;
		}
		return string;
	}
	function unCleanLabel(string) {
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
			if (iFirst!=iLast) {
				string = string.substring(0, iFirst) + string.substring(iFirst + lengthOf(unwantedDupes[i]));
				i = -1; /* check again */
			}
		}
		unwantedDbls = newArray("_-", "-_", "__", "--", "\\+\\+");
		for (i=0; i<lengthOf(unwantedDbls); i++){
			iFirst = indexOf(string, unwantedDbls[i]);
			if (iFirst>=0) {
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
			if (endsWith(preString, unwantedSuffixes[i])) {
				preString = substring(preString, 0, sL-lengthOf(unwantedSuffixes[i])); /* cleanup previous suffix */
				i=-1; /* check one more time */
			}
		}
		if (!endsWith(preString, "_lzw") && !endsWith(preString, "_lzw.")) preString = replace(preString, "_lzw", ""); /* Only want to keep this if it is at the end */
		string = preString + extString;
		/* End of suffix cleanup */
		return string;
	}