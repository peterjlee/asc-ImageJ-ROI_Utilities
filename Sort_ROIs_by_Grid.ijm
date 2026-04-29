/*  Original method by Volker Backer via https://www.reddit.com/r/ImageJ/comments/qleu36/reordering_particlesrois/
Sorts ROIs of a rectangular grid into row/column order
Created for automatically created grids of microhardness indents so subsequent ROI montages are in the expected row/column order.
Requires that rows do not overlap and ROIS are already in xy order as would be expected from *Analyze Particles*
- Sorts ROIs 
- Adds row and column numbers to ROI name
- Appends original ROI name to final ROI name for reference.
- Option to add ROI names to re-measured Results Table
	v260420 1st ASC mod (just adds user input via dialog).
	v260421 Renames original Results table if called results to avoid add to original when re-Measuring. Adds prefs. Adds diagnotics option.
	v260428 Retains original name as suffix to sequential number and also add Row and Column number. Does not need an open table.
	v260429: More descriptive. Better handling of no ROIs. Saves more settings.Fixed table renaming.
 */
macroL = "Sort_ROIs_by_Grid_v260429.ijm";
prefsNameKey = "asc_sortROIGrid.";
if (isOpen("ROI Manager"))
    nROIs = RoiManager.size();
else {
    roiPath = File.openDialog("Select ROI set to open");
	if (File.exists(roiPath)){
		if (resetROIS) roiManager("reset");
		roiManager("Open", roiPath);
		nROIs = RoiManager.size();
	}
	else exit("No ROI set available to work with");
}
if (nROIs < 2) exit("Only " + nROIs + " so no sorting possible");
rowsN = nROIs;
for (i = 2; i < nROIs / 2; i++){
	if (Math.floor(nROIs / i) == Math.ceil(nROIs / i)) rowsN = i;
	i = nROIs;
}
rowsN = call("ij.Prefs.get", prefsNameKey + "rowsN", rowsN);
tableN = Table.size();
closeUnsorted = call("ij.Prefs.get", prefsNameKey + "closeUnsorted", true);
if (tableN == 0) tableName = "";
else if (tableN != nROIs) exit("Mismatch between number of Results \(" + tableN + "\), and the number of ROIs \(" + nROIs + "\)");
else tableName = Table.title;
 /* ASC message theme */
infoColor = "#006db0"; /* Honolulu blue */
instructionColor = "#798541"; /* green_dark_modern (121,133,65) AKA Wasabi */
infoWarningColor = "#ff69b4"; /* pink_modern AKA hot pink */
infoFontSize = 12;
/*********************/
Dialog.create(macroL);
Dialog.addMessage("Requirement: Rectangular grid with non-overlapping rows" +
	"\n      \(i.e. Analyze Particles generated ROIs will be in row order\)", infoFontSize, infoWarningColor);
Dialog.addMessage("Column count: As the " + nROIs + "objects are in a rectangular grid" +
	"\n      only the row count is needed . . .", infoFontSize, instructionColor);
Dialog.addNumber("Number of rows", rowsN, 0, 3, "a row count of " + rowsN + " yields a column count of " + nROIs / rowsN);
Dialog.addCheckbox("Measure ROIs after sorting, creating a new sorted Results Table", call("ij.Prefs.get", prefsNameKey + "reMeasure", true));
if (tableName != "") Dialog.addCheckbox("Close original " + tableName + " table", call("ij.Prefs.get", prefsNameKey + "closeUnsorted", true));
Dialog.addCheckbox("Add ROI names to new Results table", call("ij.Prefs.get", prefsNameKey + "addNamesToTable", true));
Dialog.addCheckbox("Append ''_ColumnSortedROIs'' to name of sorted Results table", call("ij.Prefs.get", prefsNameKey + "renameTable", true));
Dialog.addCheckbox("Diagnostics", false);
Dialog.show();
rowsN = Dialog.getNumber();
call("ij.Prefs.set", prefsNameKey + "rowsN", rowsN);
columnsN = nROIs / rowsN;
if (nROIs != rowsN * round(columnsN) || nROIs != rowsN * Math.ceil(columnsN)) exit("Either this is not a rectangular grid or the row count \(" + rowsN + "\) is incorrect ");
reMeasure = Dialog.getCheckbox();
call("ij.Prefs.set", prefsNameKey + "reMeasure", reMeasure);
if (tableName != "") closeUnsorted = Dialog.getCheckbox();
call("ij.Prefs.set", prefsNameKey + "closeUnsorted", closeUnsorted);
addNamesToTable = Dialog.getCheckbox();
call("ij.Prefs.set", prefsNameKey + "addNamesToTable", addNamesToTable);
renameTable = Dialog.getCheckbox();
call("ij.Prefs.set", prefsNameKey + "renameTable", renameTable);
diagnostics = Dialog.getCheckbox();
if (maxOf(rowsN, columnsN) > 52) exit(maxOf(rowsN, columnsN) + " exceeds the maximum number of columns or rows, this can easily \(if tediously\) be extended if there is a need");
columnNames = newArray(columnsN);
padN = lengthOf(d2s(columnsN, 0));
for (i = 0; i < columnsN; i++) columnNames[i] = "C" + IJ.pad(i + 1, padN);
rowNames = newArray(rowsN);
padN = lengthOf(d2s(rowsN, 0));
for (i = 0; i < rowsN; i++) rowNames[i] = "R" + IJ.pad(i + 1, padN);
for (row = 0; row < rowsN; row++) {
    xCenters = newArray();
    for (column = 0; column < columnsN; column++) {
        roiManager("select", columnsN * row + column);
        getSelectionBounds(x, null, width, null);
        xCenters = Array.concat(xCenters, x + width / 2);
    }
    rankPositions = Array.rankPositions(Array.rankPositions(xCenters));
    if (diagnostics){
		IJ.log("Row " + row + " xCenters:");
		Array.print(xCenters);
		IJ.log("Row " + row + " rankPositions:");
		Array.print(rankPositions);
	}
    for (column = 0; column < columnsN; column++) {
        roiManager("select", columnsN * row + column);
        roiManager("rename", rowNames[row] + "-" + columnNames[rankPositions[column]] + " " + Roi.getName);
    }
}
roiManager("Deselect");
roiManager("Sort");
padN = lengthOf(d2s(nROIs, 0));
newNames = newArray(nROIs); /* Can be used later to add ROI names to Results */
for (i = 0; i < nROIs; i++) {
    roiManager("select", i);
	newNames[i] = IJ.pad(i + 1, padN) + " " + Roi.getName;
    roiManager("Rename", newNames[i]);
}
if (tableName != "") {
	if (closeUnsorted){
		selectWindow(tableName);
		run("Close");
	}
}
roiManager("Show None");
roiManager("Show All");
/* Re-"Measure" the ROIs in the ROI manager */
if (reMeasure){
	if (!closeUnsorted && tableName == "Results") Table.rename("Results", "Unsorted_Results");
	roiManager("Measure");
	if (addNamesToTable) Table.setColumn("ROI", newNames);
	if (renameTable) Table.rename(Table.title, Table.title + "_ColumnSortedROIs");
}