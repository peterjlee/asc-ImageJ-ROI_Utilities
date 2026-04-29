/* Set color and tranparency of ROIs
 *  v260205:	1st version Peter J. Lee, Applied Superconductivity Center
 *	v260206:	Added roiManager("Update") to save changes.
 *	v260212-24:	Added reverse color discovery. Added RGB color entry option. Uses standard ImageJ colors if possible. Added comments.
 *	v260325		Updated extended colors.
 */
macroL = "ROI_set_Color_and_Transparency_v260325";
if (nImages < 1) exit("Macro requires at least one open image");
if (Roi.size < 1) exit("Need to select ROI first");
ascPrefsKey = "asc.ROI.prefs.";
/* Now load built-in and extended color array into memory, this included RGB and hex values to facilitate reverse of saved hex values to recognisable color names */
extendedColorSpecs = loadExtendedColors();
/* Can only return single array from function so this array is design to be further split into names, RGBs and Hex values */
colorNames = newArray();
colorRGBs = newArray();
colorHexs = newArray();
for (i = 0; i < extendedColorSpecs.length; i++) {
    colorSpecs = split(extendedColorSpecs[i], "|");
    colorNames[i] = colorSpecs[0];
    colorRGBs[i] = colorSpecs[1];
    colorHexs[i] = colorSpecs[2];
}
/* The following array contains built-in ImageJ colors that any version should recognize, so these colors will be saved if recognised from their Hex valuess */
imageJColors = newArray("black", "white", "lightGray", "gray", "darkGray", "blue", "cyan", "green", "magenta", "orange", "pink", "red", "yellow");
imageJHexs = newArray();
for (i = 0; i < imageJColors.length; i++) {
    imageJHexI = indexOfArray(colorNames, imageJColors[i], -1);
    if (imageJHexI >= 0)
        imageJHexs[i] = colorHexs[imageJHexI];
    else exit(imageJColors[i] + " not found in colorNames");
}
allColors = Array.concat("none", colorNames);
orFillColor = Roi.getFillColor;
/* Retrieve a default fill opacity from prefs for use if current ROI is not a Hex value. Opacity <100 can only be saved in Zip archive as Hex values */
orFillOpacity = parseInt(call("ij.Prefs.get", ascPrefsKey + "fill.opacity", 100)); /* Will be overwritten if ROI already has fill transparency set as an extened Hex value */
/* Now convert orFillColor saved as hash to color name if available and opacity for easier reading */
if (startsWith(orFillColor, "#") && (lengthOf(orFillColor) == 7 || lengthOf(orFillColor) == 9 || lengthOf(orFillColor) == 10)) {
    orFillHex = toLowerCase("#" + substring(orFillColor, lengthOf(orFillColor) - 6));
    if (orFillColor.length > 7) {
        orFillOpacityHex = substring(orFillColor, 1, lengthOf(orFillColor) - 6);
        fillOpacity = 100 * parseInt(orFillOpacityHex, 16) / 255;
        if (fillOpacity == NaN) fillOpacity = 100;
    } else orFillOpacity = parseInt(call("ij.Prefs.get", ascPrefsKey + "fill.opacity", 100));
    orFillColorI = indexOfArray(colorHexs, orFillHex, -1);
    if (orFillColorI < 0) orFillColor = orFillHex;
    else orFillColor = colorNames[orFillColorI];
}
orStrokeColor = Roi.getStrokeColor;
orStrokeOpacity = parseInt(call("ij.Prefs.get", ascPrefsKey + "orStroke.opacity", 100)); /* Will be overwritten if ROI already has s stroke transparency set as an extened Hex value */
/* Now convert orStrokeColor saved as hash to color name and opacity for easier reading */
if (startsWith(orStrokeColor, "#") && (lengthOf(orStrokeColor) == 7 || lengthOf(orStrokeColor) == 9 || lengthOf(orStrokeColor) == 10)) {
    orStrokeHex = toLowerCase("#" + substring(orStrokeColor, lengthOf(orStrokeColor) - 6));
    if (orStrokeColor.length > 7) {
        orStrokeOpacityHex = substring(orStrokeColor, 1, lengthOf(orStrokeColor) - 6);
        orStrokeOpacity = 100 * parseInt(orStrokeOpacityHex, 16) / 255;
        if (orStrokeOpacity == NaN) orStrokeOpacity = 100;
    } else orStrokeOpacity = parseInt(call("ij.Prefs.get", ascPrefsKey + "stroke.opacity", 100));
    orStrokeColorI = indexOfArray(colorHexs, orStrokeHex, -1);
    if (orStrokeColorI < 0) orStrokeColor = orStrokeHex;
    else orStrokeColor = colorNames[orStrokeColorI];
}
orRoiName = Roi.getName();
orProps = Roi.getProperties();
Dialog.create(macroL + ": Generate initial phase ranges");
Dialog.addString("Rename ROI", orRoiName, Math.constrain(lengthOf(orRoiName), 25, 50));
Roi.getPosition(channel, slice, frame);
Dialog.addString("Position: channel-slice-frame", channel + "-" + slice + "-" + frame, 25);
Dialog.addNumber("Group number", Roi.getGroup, 0, 3, "0 = no group");
Dialog.addChoice("Stroke color", allColors, orStrokeColor);
Dialog.addString("Stroke color as RGB values", "r,g,b", 12);
Dialog.addSlider("Stroke opacity (%):", 0, 100, orStrokeOpacity);
Dialog.addNumber("Stroke width", Roi.getStrokeWidth, 0, 3, "pixels");
Dialog.setInsets(0, 0, 20);
Dialog.addMessage("Note that the stroke values above will not be displayed under\nROI_Manager/Properties but they are retained if saved as a Zip ROI set");
Dialog.addChoice("Fill color", allColors, orFillColor);
Dialog.addString("Fill color as RGB values", "r,g,b", 12);
Dialog.addSlider("Fill opacity (%):", 0, 100, orFillOpacity);
Dialog.addCheckbox("Table ROI-defining coordinates", false);
Dialog.addCheckbox("Table contained points \(" + Roi.size + "\)", false);
Dialog.addCheckbox("Measure ROI", false);
if (orProps != "") Dialog.addCheckbox("Print original propertes", false);
else logProps = false;
Dialog.addCheckbox("Print new values to log window", false);
Dialog.show();
roiName = Dialog.getString();
Roi.setName(roiName);
positions = split(Dialog.getString, "-");
Roi.setPosition(parseInt(positions[0]), parseInt(positions[1]), parseInt(positions[1]));
Roi.setGroup(Dialog.getNumber);
strokeColor = Dialog.getChoice();
strokeRGB = Dialog.getString();
if (strokeRGB != "r,g,b") strokeColor = strokeRGB;
strokeOpacity = Dialog.getNumber();
strokeWidth = Dialog.getNumber();
fillColor = Dialog.getChoice();
fillRGB = Dialog.getString();
if (fillRGB != "r,g,b") fillColor = fillRGB;
fillOpacity = Dialog.getNumber();
listCoordinates = Dialog.getCheckbox();
listContainedPoints = Dialog.getCheckbox();
measureROI = Dialog.getCheckbox();
if (orProps != "") logProps = Dialog.getCheckbox();
logValues = Dialog.getCheckbox();
/*
 ***** Apply and store ROI stroke values *****
 */
strokeAlpha = String.pad(toHex(255 * strokeOpacity / 100), 2);
call("ij.Prefs.set", ascPrefsKey + "stroke.opacity", strokeOpacity);
/* Check to see if any RGB values have been manually added */
if (strokeRGB != "r,g,b" && indexOf(strokeColor, ",") > 0) {
    strokeRGBs = split(strokeColor, ","); /* R,G,B values are accepotable as alternatives */
    if (strokeRGBs.length != 3) exit("Stroke color contained a comma and was assumed to be RGB but was had " + strokeRGBs.length + " commas separated values");
    strokeColor = getHexColorFromRGBArray(strokeRGBs);
} else {
    strokeColorI = indexOfArray(colorNames, strokeColor, -1);
    if (strokeColorI >= 0)
        strokeColor = colorHexs[strokeColorI];
    else strokeColor = "none";
}
/* Now add/update opacity */
if (startsWith(strokeColor, "#") && (lengthOf(strokeColor) == 7 || lengthOf(strokeColor) == 9 || lengthOf(strokeColor) == 10)) {
    strokeHex = toLowerCase("#" + substring(strokeColor, lengthOf(strokeColor) - 6));
    if (strokeOpacity < 100) strokeColor = replace(strokeHex, "#", "#" + strokeAlpha); /* New alpha overrides old */
    else strokeColor = strokeHex;
}
/* Check to see of the stroke color can be saved as a built-in ImageJ color for compatibility purposes */
imageJHexI = indexOfArray(imageJHexs, strokeColor, -1);
if (imageJHexI >= 0) strokeColor = imageJColors[imageJHexI];
/* */
call("ij.Prefs.set", ascPrefsKey + "stroke.color", strokeColor);
call("ij.Prefs.set", ascPrefsKey + "stroke.opacity", strokeOpacity);
/*
 ***** Apply and store ROI fill values ***** 
 */
fillAlpha = String.pad(toHex(255 * fillOpacity / 100), 2);
call("ij.Prefs.set", ascPrefsKey + "fill.opacity", fillOpacity);
/* Check to see if any RGB values have been manually added */
if (fillRGB != "r,g,b" && indexOf(fillRGB, ",") > 0) {
    fillRGBs = split(fillColor, ","); /* R,G,B values are accepotable as alternatives */
    if (fillRGBs.length != 3) exit("Stroke color contained a comma and was assumed to be RGB but was had " + fillRGBs.length + " commas separated values");
    fillColor = getHexColorFromRGBArray(fillRGBs);
} else {
    fillColorI = indexOfArray(colorNames, fillColor, -1);
    if (fillColorI >= 0)
        fillColor = colorHexs[fillColorI];
    else fillColor = "none";
}
/* Now add/update opacity */
if (startsWith(fillColor, "#") && (lengthOf(fillColor) == 7 || lengthOf(fillColor) == 9 || lengthOf(fillColor) == 10)) {
    fillHex = toLowerCase("#" + substring(fillColor, lengthOf(fillColor) - 6));
    if (fillOpacity < 100) fillColor = replace(fillHex, "#", "#" + fillAlpha); /* New alpha overrides old */
    else fillColor = fillHex;
}
/* Check to see of the fill color can be saved as a native ImageJ color for compatibility purposes */
imageJHexI = indexOfArray(imageJHexs, fillColor, -1);
if (imageJHexI >= 0) fillColor = imageJColors[imageJHexI];
/* */
call("ij.Prefs.set", ascPrefsKey + "fill.color", fillColor);
roiManager("Set Fill Color", fillColor);
roiManager("Set Color", strokeColor); /* Roi.setStrokeColor(color) does not seem to work */
roiManager("Set Line Width", strokeWidth); /* Roi.setStrokeWidth(width) does not seem to work */
roiManager("Update");
if (logProps) IJ.log(orProps);
if (logValues) IJ.log("For ROI " + roiName + ": Fill set to " + fillColor + ", line color " + strokeColor + ", line width " + strokeWidth);
if (listCoordinates) {
    Roi.getCoordinates(xpoints, ypoints);
    Table.showArrays("Coordinate: " + roiName, xpoints, ypoints);
}
if (listCoordinates) {
    Roi.getContainedPoints(xpoints, ypoints)
    Table.showArrays("Contained points: " + roiName, xpoints, ypoints);
}
if (measureROI) roiManager("measure");
/*
	   ( 8(|)	( 8(|)	Functions	@@@@@:-)	@@@@@:-)
*/
/*
	 Macro Color Functions
 */
	function loadExtendedColors() {
	    /* 
	    ***** Use lowercase for # colors for github style ******
	    *	v260212:	1st version  Peter J. Lee, Applied Superconductivity Center  73 colors
	    	v260216:	lightGray and darkGray changed to lightGray and darkGray to match strandard ImageJ monochromes and intensities. v260217: fixed error in list.
			v260325:	newArray added. Basic colors at top.
	    */
	    functionL = "loadExtendedColors_v260325";
		extendedColors = newArray("");
	    /* ImageJ standard colors */
	    extendedColors = Array.concat(extendedColors, "red" + "|" + "255, 0, 0" + "|" + "#ff0000");
	    extendedColors = Array.concat(extendedColors, "green" + "|" + "0, 255, 0" + "|" + "#00ff00"); /* AKA lime green */
	    extendedColors = Array.concat(extendedColors, "blue" + "|" + "0, 0, 255" + "|" + "#0000ff");
	    extendedColors = Array.concat(extendedColors, "cyan" + "|" + "0, 255, 255" + "|" + "#00ffff");
	    extendedColors = Array.concat(extendedColors, "yellow" + "|" + "255, 255, 0" + "|" + "#ffff00");
	    extendedColors = Array.concat(extendedColors, "magenta" + "|" + "255, 0, 255" + "|" + "#ff00ff");
	    extendedColors = Array.concat(extendedColors, "pink" + "|" + "255, 192, 203" + "|" + "#ffc0cb");
	    extendedColors = Array.concat(extendedColors, "orange" + "|" + "255, 165, 0" + "|" + "#ffa500");
	    /* Not-always-strandard ImageJ color */
	    extendedColors = Array.concat(extendedColors, "violet" + "|" + "127, 0, 255" + "|" + "#7f00ff");
		/* ImageJ monochrome */
	    extendedColors = newArray("white" + "|" + "255, 255, 255" + "|" + "#ffffff");
	    extendedColors = Array.concat(extendedColors, "black" + "|" + "0, 0, 0" + "|" + "#000000");
	    extendedColors = Array.concat(extendedColors, "lightGray" + "|" + "192, 192, 192" + "|" + "#c0c0c0");
	    extendedColors = Array.concat(extendedColors, "gray" + "|" + "127, 127, 127" + "|" + "#7f7f7f");
	    extendedColors = Array.concat(extendedColors, "darkGray" + "|" + "64, 64, 64" + "|" + "#404040");
	    /* slightly non-white and non-black values to distinguish from white and black transparency */
	    extendedColors = Array.concat(extendedColors, "off-white" + "|" + "245, 245, 245" + "|" + "#f5f5f5");
	    extendedColors = Array.concat(extendedColors, "off-black" + "|" + "10, 10, 10" + "|" + "#0a0a0a");
	    /* materials */
	    extendedColors = Array.concat(extendedColors, "bronze" + "|" + "205, 127, 50" + "|" + "#cd7f32");
	    extendedColors = Array.concat(extendedColors, "antique_bronze" + "|" + "102, 93, 30" + "|" + "#665d1e");
	    extendedColors = Array.concat(extendedColors, "brass" + "|" + "181, 166, 66" + "|" + "#b5a642");
	    extendedColors = Array.concat(extendedColors, "dull_brass" + "|" + "142, 124, 80" + "|" + "#8e7c50");
	    extendedColors = Array.concat(extendedColors, "brick" + "|" + "192, 80, 77" + "|" + "#c0504d");
	    extendedColors = Array.concat(extendedColors, "burnished_gold" + "|" + "133, 109, 77" + "|" + "#856d4d");
	    extendedColors = Array.concat(extendedColors, "chrome" + "|" + "229, 228, 226" + "|" + "#e5e4e2");
	    extendedColors = Array.concat(extendedColors, "copper" + "|" + "184, 115, 51" + "|" + "#b87333");
	    extendedColors = Array.concat(extendedColors, "aged_copper" + "|" + "110, 58, 7" + "|" + "#6e3a07");
	    extendedColors = Array.concat(extendedColors, "dusky_copper" + "|" + "110, 59, 59" + "|" + "#6e3b3b");
	    extendedColors = Array.concat(extendedColors, "light_copper" + "|" + "218, 138, 103" + "|" + "#da8a67");
	    extendedColors = Array.concat(extendedColors, "slate_gray" + "|" + "112, 128, 144" + "|" + "#708090");
	    extendedColors = Array.concat(extendedColors, "titanium" + "|" + "135, 134, 129" + "|" + "#878681");
	    /* excel modern + */
	    extendedColors = Array.concat(extendedColors, "aqua_modern" + "|" + "75, 172, 198" + "|" + "#4bacc6"); /* AKA viking aqua */
	    extendedColors = Array.concat(extendedColors, "blue_accent_modern" + "|" + "79, 129, 189" + "|" + "#4f81bd");
	    extendedColors = Array.concat(extendedColors, "blue_dark_modern" + "|" + "31, 73, 125" + "|" + "#1f497d");
	    extendedColors = Array.concat(extendedColors, "blue_honolulu" + "|" + "0, 118, 182" + "|" + "#006db0");
	    extendedColors = Array.concat(extendedColors, "blue_modern" + "|" + "58, 93, 174" + "|" + "#3a5dae");
	    extendedColors = Array.concat(extendedColors, "gray_modern" + "|" + "83, 86, 90" + "|" + "#53565"); /* abright gray */
	    extendedColors = Array.concat(extendedColors, "green_dark_modern" + "|" + "121, 133, 65" + "|" + "#798541"); /* wasabi */
	    extendedColors = Array.concat(extendedColors, "green_modern" + "|" + "155, 187, 89" + "|" + "#9bbb59"); /* AKA "chelsea cucumber" */
	    extendedColors = Array.concat(extendedColors, "green_modern_accent" + "|" + "214, 228, 187" + "|" + "#d6e4bb"); /* AKA "gin" */
	    extendedColors = Array.concat(extendedColors, "green_spring_accent" + "|" + "0, 255, 102" + "|" + "#00ff66"); /* AKA "spring green" */
	    extendedColors = Array.concat(extendedColors, "orange_modern" + "|" + "247, 150, 70" + "|" + "#f79646"); /* tan hide, light orange */
	    extendedColors = Array.concat(extendedColors, "pink_modern" + "|" + "255, 105, 180" + "|" + "#ff69b4"); /* AKA hot pink */
	    extendedColors = Array.concat(extendedColors, "purple_modern" + "|" + "128, 100, 162" + "|" + "#8064a2"); /* AKA blue-magenta, purple paradise */
	    extendedColors = Array.concat(extendedColors, "red_modern" + "|" + "227, 24, 55" + "|" + "#e31837");
	    extendedColors = Array.concat(extendedColors, "tan_modern" + "|" + "238, 236, 225" + "|" + "#eeece1");
	    extendedColors = Array.concat(extendedColors, "violet_modern" + "|" + "76, 65, 132" + "|" + "#4c4184");
	    extendedColors = Array.concat(extendedColors, "yellow_modern" + "|" + "247, 238, 69" + "|" + "#f7ee45");
	    /* fsu */
	    extendedColors = Array.concat(extendedColors, "garnet" + "|" + "120, 47, 64" + "|" + "#782f40");
	    extendedColors = Array.concat(extendedColors, "gold" + "|" + "206, 184, 136" + "|" + "#ceb888");
	    extendedColors = Array.concat(extendedColors, "gulf_sands" + "|" + "223, 209, 167" + "|" + "#dfd1a7");
	    extendedColors = Array.concat(extendedColors, "stadium_night" + "|" + "16, 24, 32" + "|" + "#101820");
	    extendedColors = Array.concat(extendedColors, "westcott_water" + "|" + "92, 184, 178" + "|" + "#5cb8b2");
	    extendedColors = Array.concat(extendedColors, "vault_garnet" + "|" + "166, 25, 46" + "|" + "#a6192e");
	    extendedColors = Array.concat(extendedColors, "legacy_blue" + "|" + "66, 85, 99" + "|" + "#425563");
	    extendedColors = Array.concat(extendedColors, "plaza_brick" + "|" + "66, 85, 99" + "|" + "#572932");
	    extendedColors = Array.concat(extendedColors, "vault_gold" + "|" + "255, 199, 44" + "|" + "#ffc72c");
	    /* fluorescent colors https://www.w3schools.com/colors/colors_crayola.asp */
	    extendedColors = Array.concat(extendedColors, "radical_red" + "|" + "255, 53, 94" + "|" + "#ff355e");
	    extendedColors = Array.concat(extendedColors, "jazzberry_jam" + "|" + "165, 11, 94" + "|" + "#a50b5e");
	    extendedColors = Array.concat(extendedColors, "wild_watermelon" + "|" + "253, 91, 120" + "|" + "#fd5b78");
	    extendedColors = Array.concat(extendedColors, "shocking_pink" + "|" + "255, 110, 255" + "|" + "#ff6eff"); /* ultra pink */
	    extendedColors = Array.concat(extendedColors, "razzle_dazzle_rose" + "|" + "238, 52, 210" + "|" + "#ee34d2");
	    extendedColors = Array.concat(extendedColors, "hot_magenta" + "|" + "255, 0, 204" + "|" + "#ff00cc"); /* AKA purple pizzazz */
	    extendedColors = Array.concat(extendedColors, "outrageous_orange" + "|" + "255, 96, 55" + "|" + "#ff6037");
	    extendedColors = Array.concat(extendedColors, "supernova_orange" + "|" + "255, 191, 63" + "|" + "ffbf3f"); /* supernova neon orange*/
	    extendedColors = Array.concat(extendedColors, "sunglow" + "|" + "255, 204, 51" + "|" + "#ffcc33");
	    extendedColors = Array.concat(extendedColors, "neon_carrot" + "|" + "255, 153, 51" + "|" + "#ff9933");
	    extendedColors = Array.concat(extendedColors, "atomic_tangerine" + "|" + "255, 153, 102" + "|" + "#ff9966");
	    extendedColors = Array.concat(extendedColors, "laser_lemon" + "|" + "255, 255, 102" + "|" + "#ffff66"); /* AKA unmellow yellow */
	    extendedColors = Array.concat(extendedColors, "electric_lime" + "|" + "204, 255, 0" + "|" + "#ccff00");
	    extendedColors = Array.concat(extendedColors, "screamin'_green" + "|" + "102, 255, 102" + "|" + "#66ff66");
	    extendedColors = Array.concat(extendedColors, "magic_mint" + "|" + "170, 240, 209" + "|" + "#aaf0d1");
	    extendedColors = Array.concat(extendedColors, "blizzard_blue" + "|" + "80, 191, 230" + "|" + "#50bfe6"); /* AKA  malibu */
	    extendedColors = Array.concat(extendedColors, "dodger_blue" + "|" + "9, 159, 255" + "|" + "#099fff"); /* AKA dodger neon blue */
	    return extendedColors;
	}
	function getHexColorFromRGBArray(rgbArray) {
		/* v240821: 1st Version */
		 r = toHex(rgbArray[0]); g = toHex(rgbArray[1]); b = toHex(rgbArray[2]);
		 hexName= "#" + "" + String.pad(r, 2) + "" + String.pad(g, 2) + "" + String.pad(b, 2);
		 return hexName;
	}
	function indexOfArray(array, value, default){
		/* v190423 Adds "default" parameter (use -1 for backwards compatibility). Returns only first found value
			v230902 Limits default value to array size */
		index = minOf(lengthOf(array) - 1, default);
		for (i=0; i<lengthOf(array); i++){
			if (array[i]==value){
				index = i;
				i = lengthOf(array);
			}
		}
	  return index;
	}