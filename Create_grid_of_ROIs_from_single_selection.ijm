  macro "Create_grid_of_ROIs_from_single_selection" {
 /* Creates a square grid of ROIs that are identical to the current selection
	Original purpose was to create ROIs for scanned 35 mm film strips
	v240216: 1st version PJL Applied Superconductivity Center, NHMFL, FSU
	v240220: Opens ROI manager if not open.
	v240223: Improved dialog.
	*/
	macroL = "Create_grid_of_ROIs_from_single_selection_v240220.ijm";
	if (nImages==0) exit("Sorry this macro needs an image to save, goodbye");
	getDimensions(imageWidth, imageHeight, null, null, null);
	selType = selectionType;
	if (selType>=0)
		getSelectionBounds(selPosStartX, selPosStartY, originalSelEWidth, originalSelEHeight);
		/*  smallest rectangle that can completely contain the current selection */
	else exit("Solid selection required for ROI creation");
	prefsNameKey = "asc.roi.";
	if (isOpen("ROI Manager"))
		nROIs = RoiManager.size();
	else {
		nROIs=0;
		run("ROI Manager...");
	}
	/* ASC Dialog style */
	infoColor = "#006db0"; /* Honolulu blue */
	instructionColor = "#798541"; /* green_dark_modern (121, 133, 65) AKA Wasabi */
	infoWarningColor = "#ff69b4"; /* pink_modern AKA hot pink */
	infoFontSize = 12;
	Dialog.create("New ROI distribution: " + macroL);
		Dialog.addMessage("From an initial selection, a grid of duplicate ROIs is created\nIt assumes that you original selection is top-left of your grid", infoFontSize, infoColor);
		Dialog.addNumber("Max ROIs to be created \(including original\)", 0, 0, 3, "ROIs");
		Dialog.setInsets(-2, 50, 10);
		Dialog.addMessage("Leave max ROIs as zero for unrestricted", infoFontSize, instructionColor);
		rowN = call("ij.Prefs.get", "asc.roi.rowN", 1);
		Dialog.addNumber("Rows", rowN, 0, 3, "");
		columnN = call("ij.Prefs.get", "asc.roi.columnN", 1);
		Dialog.addNumber("Columns", columnN, 0, 3, "");
		Dialog.addCheckbox("Create grid coordinates by moving selection to furthest location . . . ", true);
		Dialog.addMessage(". . . else use margins below . . . ", infoFontSize, instructionColor);
		canvasMX = call("ij.Prefs.get", "asc.roi.canvasMX", 4);
		canvasMY = call("ij.Prefs.get", "asc.roi.canvasMY", 4);
		Dialog.addNumber("Canvas margin: left/right", canvasMX, 2, 3, "%");
		Dialog.addNumber("Canvas margin: top/bottom", canvasMY, 2, 3, "%");
		Dialog.addMessage("If you reposition ROIs after the macro has run . . . \n. . . remember to click the 'Update' button in the ROI manager", infoFontSize, infoWarningColor);
	Dialog.show();
		maxRN = Dialog.getNumber();
		rowN = Dialog.getNumber();
		columnN = Dialog.getNumber();
		selectFinal = Dialog.getCheckbox();
		canvasMX = Dialog.getNumber();
		canvasMY = Dialog.getNumber();
	if (maxRN==0) maxRN = rowN * columnN;
	call("ij.Prefs.set", "asc.roi.maxRN", maxRN);
	call("ij.Prefs.set", "asc.roi.rowN", rowN);
	call("ij.Prefs.set", "asc.roi.columnN", columnN);
	// call("ij.Prefs.set", "asc.roi.distType", distType);
	setSelectionName("row " + 0 + ", column " + 0);
	roiManager("Add");
	roiManager("Deselect");
	if (selectFinal){
		waitForUser("Move selection to final location then click OK");
		getSelectionBounds(selPosEndX, selPosEndY, endSelEWidth, endSelEHeight);
		xIncr = (selPosEndX - selPosStartX) / (columnN - 1);
		yIncr = (selPosEndY - selPosStartY) / (rowN - 1);
		/* The following is not useful here but sets up preferences for the next use */
		canvasMX = 100 * (imageWidth - selPosEndX - endSelEWidth) / imageWidth;
		canvasMY = 100 * (imageHeight - selPosEndY - endSelEHeight) / imageHeight;
	}
	else {
		canvasFX = 1 - canvasMX / 100;
		canvasFY = 1 - canvasMY / 100;
		xIncr = ((canvasFX * imageWidth) - selPosStartX - originalSelEWidth) / (columnN - 1);
		yIncr = ((canvasFY * imageHeight) - selPosStartY - originalSelEHeight) / (rowN - 1);
	}
	call("ij.Prefs.set", "asc.roi.canvasMX", canvasMX);
	call("ij.Prefs.set", "asc.roi.canvasMY", canvasMY);
	setBatchMode(true);
	run("Select None");
	for (r=0, t=1; r<rowN && t<maxRN; r++){
		for (c=0; c<columnN && t<maxRN; c++){
			if (r>0 || c>0){
				RoiManager.selectByName("row " + 0 + ", column " + 0);
				run("Translate... ", "x=" + c * xIncr + " y=" + r * yIncr);
				setSelectionName("row " + r + ", column " + c);
				roiManager("Add");
				t++;
			}
		}
	}
	setBatchMode("exit and display");
	showStatus(t + " ROIs created using " + macroL, "flash green");
}
	