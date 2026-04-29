  macro "Create same style overlays for all ROIs" {
 /* Peter J. Lee: Applied Superconductivity Center, National High Magnetic Field Laboratory
	v230713: Detects selection, adds stroke with and color preferences and sound confirmation.
	v230714: Expanded shadow to make sure there are no gaps between shadow and outline. Add shadow drop distance option.
	v230720: Does not unnecessarily open the ROI manager.
	v230725: Should not move the ROIs. Some simplification. F1: getColorArrayFromColorName_v230908. F3: Replaced function: pad.
	v231209: Opacity options added. f1: Updated getColorFromColorName function (012324); updated colors 020526.
	*/
	macroL = "Create_same_style_Overlays_for_each_ROI_v231209-f2.ijm";
	saveSettings();
	prefsNameKey = "asc.roi.";
	if (isOpen("ROI Manager")){
		nROIs = roiManager("count");
		if (nROIs==0) close("ROI Manager");
	}
	else nROIs = 0;
	if (nROIs<1) exit("Sorry, this macro needs ROIs to outline");
	nOverlays = Overlay.size;
	strokeColor = call("ij.Prefs.get", "asc.roi.stroke.color","yellow");
	strokeWidth = parseInt(call("ij.Prefs.get", "asc.roi.stroke.width",1));
	shadowChoices = newArray("black", "off-black", "darkGray", "gray", "lightGray", "off-white", "white");
	colorChoicesStd = newArray("red", "green", "blue", "cyan", "magenta", "yellow", "pink", "orange", "violet");
	colorChoicesMaterials = newArray("bronze", "antique_bronze", "brass", "dull_brass", "brick", "chrome", "copper", "aged_copper", "dusky_copper", "light_copper", "garnet", "burnished_gold", "gold", "slate_gray", "titanium", "vault_garnet", "plaza_brick", "vault_gold");
	colorChoicesMod = newArray("aqua_modern", "blue_accent_modern", "blue_dark_modern", "blue_modern", "blue_honolulu", "gray_modern", "green_dark_modern", "green_modern", "green_modern_accent", "green_spring_accent", "orange_modern", "pink_modern", "purple_modern", "red_modern", "tan_modern", "violet_modern", "yellow_modern");
	colorChoicesNeon = newArray("jazzberry_jam", "radical_red", "wild_watermelon", "outrageous_orange", "supernova_orange", "atomic_tangerine", "neon_carrot", "sunglow", "laser_lemon", "electric_lime", "screamin'_green", "magic_mint", "blizzard_blue", "dodger_blue", "shocking_pink", "razzle_dazzle_rose", "hot_magenta");
	colorChoices = Array.concat(colorChoicesStd, colorChoicesMaterials, colorChoicesMod, colorChoicesNeon, shadowChoices);
	Dialog.create("Overlay options: " + macroL);
		Dialog.addChoice("Color of ROI overlay outline", colorChoices, call("ij.Prefs.get", prefsNameKey + "stroke.color","yellow"));
		Dialog.addNumber("Stroke width width of ROI overlay", parseInt(call("ij.Prefs.get", prefsNameKey + "stroke.width",1)), 0, 3, "pixels");
		strokeOpacity = parseInt(call("ij.Prefs.get", prefsNameKey + "stroke.opacity", "50"));
		Dialog.addSlider("Stroke opacity", 0, 100, strokeOpacity);
		shadowOpacity = parseInt(call("ij.Prefs.get", prefsNameKey + "shadow.opacity", "50"));
		Dialog.addSlider("Shadow opacity \(0=no shadow\)", 0, 100, shadowOpacity);
		Dialog.addNumber("Shadow drop as multiplier of stroke width", parseInt(call("ij.Prefs.get", prefsNameKey + "shadowdrop.multiplier",1)), 0, 3, "multiplier");
		Dialog.addChoice("Color of ROI overlay fill", colorChoices, call("ij.Prefs.get", prefsNameKey + "fill.color", "yellow"));
		fillOpacity = parseInt(call("ij.Prefs.get", prefsNameKey + "fill.opacity", 0));
		Dialog.addSlider("Fill opacity \(0=no fill\)", 0, 100, fillOpacity);
		if (nOverlays>0) Dialog.addCheckbox("Image already has " + nOverlays + " overlays; remove them first?",true);
	Dialog.show();
		strokeColor = Dialog.getChoice();
		strokeWidth = Dialog.getNumber();
		strokeOpacity = Dialog.getNumber();
		shadowOpacity = Dialog.getNumber();
		shadowDropN = Dialog.getNumber();
		fillColor = Dialog.getChoice();
		fillOpacity = Dialog.getNumber();
		if (Dialog.getCheckbox) Overlay.clear;
		shadowDrop = round(shadowDropN * strokeWidth);
		shadowStroke = floor(1.5 * strokeWidth * abs(shadowDropN));
	call("ij.Prefs.set", prefsNameKey + "stroke.color", strokeColor);
	call("ij.Prefs.set", prefsNameKey + "stroke.width", strokeWidth);
	call("ij.Prefs.set", prefsNameKey + "stroke.opacity", strokeOpacity);
	call("ij.Prefs.set", prefsNameKey + "shadow.opacity", shadowOpacity);
	call("ij.Prefs.set", prefsNameKey + "shadowdrop.multiplier",shadowDropN);
	call("ij.Prefs.set", prefsNameKey + "fill.color",fillColor);
	call("ij.Prefs.set", prefsNameKey + "fill.opacity", fillOpacity);
	if (!startsWith(strokeColor, "#")) strokeHex = getHexColorFromColorName(strokeColor);
	else strokeHex = strokeColor;
	if (strokeOpacity<100) strokeHex = replace(strokeHex, "#", "#" + String.pad(toHex(255 * strokeOpacity/100), 2));
	shadowHex = "#" + "" + String.pad(toHex(255 * shadowOpacity/100), 2) + "" + "000000";
	if (!startsWith(fillColor, "#")) fillHex = getHexColorFromColorName(fillColor);
	else fillHex = fillColor;
	if (fillOpacity<100) fillHex = replace(fillHex, "#", "#" + String.pad(toHex(255 * fillOpacity/100), 2));
	setBatchMode(true);
	print(fillHex);
	overlayN = Overlay.size();
	roiManager("Show None");
	for (i=0; i<nROIs; i++){
		roiManager("Select", i);
		roiName = Roi.getName;
		if (shadowOpacity>0){
			getSelectionBounds(x, y, null, null);
			setSelectionLocation(x + shadowDrop, y + shadowDrop);
			setSelectionName(roiName + "_" + shadowOpacity + "-shadow");
			ovOptions = "width=" + strokeWidth + " stroke=" + shadowHex;
			run("Add Selection...", ovOptions);
			roiManager("Deselect");
		}
		roiManager("Select", i);
		ovOptions = "";
		if (fillOpacity>0) ovOptions += "fill=" + fillHex;
		if (strokeOpacity>0 && strokeWidth>0) ovOptions += " width=" + strokeWidth + " stroke=" + strokeHex;
		if (ovOptions!="") run("Add Selection...", ovOptions);
	}
	roiManager("Deselect");
	run("Select None");
	setBatchMode("exit and display");
	restoreSettings;
  }
   	/*
	Color Functions
	*/
	function getColorArrayFromColorName(colorName) {
		/* v180828 added Fluorescent Colors
		   v181017-8 added off-white and off-black for use in gif transparency and also added safe exit if no color match found
		   v191211 added Cyan
		   v211022 all names lower-case, all spaces to underscores v220225 Added more hash value comments as a reference v220706 restores missing magenta
		   v230130 Added more descriptions and modified order.
		   v230908: Returns "white" array if not match is found and logs issues without exiting.
		   v240123: Removed duplicate entries: Now 53 unique colors.
		   v240709: Added 2024 FSU-Branding Colors. Some reorganization. Now 60 unique colors.
		   v260202: Added 12 (mostly metallic) "Materials" colors. Now 72 unique colors.
		   v260213: red_n_modern becomes red_modern and old red_modern becomes brick;
		*/
		functionL = "getColorArrayFromColorName_v240709";
		cA = newArray(255, 255, 255); /* defaults to white */
		if (colorName == "white") cA = newArray(255, 255, 255);
		else if (colorName == "black") cA = newArray(0, 0, 0);
		else if (colorName == "off-white") cA = newArray(245, 245, 245);
		else if (colorName == "off-black") cA = newArray(10, 10, 10);
		else if (colorName == "lightGray") cA = newArray(192, 192, 192);
		else if (colorName == "gray") cA = newArray(127, 127, 127);
		else if (colorName == "darkGray") cA = newArray(64, 64, 64);
		else if (colorName == "red") cA = newArray(255, 0, 0);
		else if (colorName == "green") cA = newArray(0, 255, 0);						/* #00FF00 AKA Lime green */
		else if (colorName == "blue") cA = newArray(0, 0, 255);
		else if (colorName == "cyan") cA = newArray(0, 255, 255);
		else if (colorName == "yellow") cA = newArray(255, 255, 0);
		else if (colorName == "magenta") cA = newArray(255, 0, 255);					/* #FF00FF */
		else if (colorName == "pink") cA = newArray(255, 192, 203);
		else if (colorName == "violet") cA = newArray(127, 0, 255);
		else if (colorName == "orange") cA = newArray(255, 165, 0);
			/* Excel Modern  + */
		else if (colorName == "aqua_modern") cA = newArray(75, 172, 198);			/* #4bacc6 AKA "Viking" aqua */
		else if (colorName == "blue_accent_modern") cA = newArray(79, 129, 189);	/* #4f81bd */
		else if (colorName == "blue_dark_modern") cA = newArray(31, 73, 125);		/* #1F497D */
		else if (colorName == "blue_honolulu") cA = newArray(0, 118, 182);			/* Honolulu Blue #006db0 */
		else if (colorName == "blue_modern") cA = newArray(58, 93, 174);			/* #3a5dae */
		else if (colorName == "gray_modern") cA = newArray(83, 86, 90);				/* bright gray #53565A */
		else if (colorName == "green_dark_modern") cA = newArray(121, 133, 65);		/* Wasabi #798541 */
		else if (colorName == "green_modern") cA = newArray(155, 187, 89);			/* #9bbb59 AKA "Chelsea Cucumber" */
		else if (colorName == "green_modern_accent") cA = newArray(214, 228, 187); 	/* #D6E4BB AKA "Gin" */
		else if (colorName == "green_spring_accent") cA = newArray(0, 255, 102);	/* #00FF66 AKA "Spring Green" */
		else if (colorName == "orange_modern") cA = newArray(247, 150, 70);			/* #f79646 tan hide, light orange */
		else if (colorName == "pink_modern") cA = newArray(255, 105, 180);			/* hot pink #ff69b4 */
		else if (colorName == "purple_modern") cA = newArray(128, 100, 162);		/* blue-magenta, purple paradise #8064A2 */
		else if (colorName == "red_modern") cA = newArray(227, 24, 55);
		else if (colorName == "tan_modern") cA = newArray(238, 236, 225);
		else if (colorName == "violet_modern") cA = newArray(76, 65, 132);
		else if (colorName == "yellow_modern") cA = newArray(247, 238, 69);
			/* FSU */
		else if (colorName == "garnet") cA = newArray(120, 47, 64);					/* #782F40 */
		else if (colorName == "gold") cA = newArray(206, 184, 136);					/* #CEB888 */
		else if (colorName == "gulf_sands") cA = newArray(223, 209, 167);				/* #DFD1A7 */
		else if (colorName == "stadium_night") cA = newArray(16, 24, 32);				/* #101820 */
		else if (colorName == "westcott_water") cA = newArray(92, 184, 178);			/* #5CB8B2 */
		else if (colorName == "vault_garnet") cA = newArray(166, 25, 46);				/* #A6192E */
		else if (colorName == "legacy_blue") cA = newArray(66, 85, 99);				/* #425563 */
		else if (colorName == "plaza_brick") cA = newArray(66, 85, 99);				/* #572932 */
		else if (colorName == "vault_gold") cA = newArray(255, 199, 44);				/* #FFC72C */
			/* Materials */
		else if (colorName == "bronze") cA = newArray(205, 127, 50);					/* #CD7F32 */
		else if (colorName == "antique_bronze") cA = newArray(102, 93, 30);			/* #665D1E */
		else if (colorName == "brass") cA = newArray(181, 166, 66);					/* #B5A642 */
		else if (colorName == "brick") cA = newArray(192, 80, 77);
		else if (colorName == "dull_brass") cA = newArray(142, 124, 80);				/* #8E7C50 */
		else if (colorName == "burnished_gold") cA = newArray(133, 109, 77);			/* #856D4D */
		else if (colorName == "chrome") cA = newArray(229, 228, 226);					/* #E5E4E2 */
		else if (colorName == "copper") cA = newArray(184, 115, 51);					/* #B87333 */
		else if (colorName == "aged_copper") cA = newArray(110, 58, 7);				/* #6E3A07 */
		else if (colorName == "dusky_copper") cA = newArray(110, 59, 59);				/* #6E3B3B */
		else if (colorName == "light_copper") cA = newArray(218, 138, 103);			/* #DA8A67 */
		else if (colorName == "slate_gray") cA = newArray(112, 128, 144);				/* #708090 */
		else if (colorName == "titanium") cA = newArray(135, 134, 129);				/* #878681 */
		   /* Fluorescent Colors https://www.w3schools.com/colors/colors_crayola.asp   */
		else if (colorName == "radical_red") cA = newArray(255, 53, 94);			/* #FF355E */
		else if (colorName == "jazzberry_jam") cA = newArray(165, 11, 94);
		else if (colorName == "wild_watermelon") cA = newArray(253, 91, 120);		/* #FD5B78 */
		else if (colorName == "shocking_pink") cA = newArray(255, 110, 255);		/* #FF6EFF Ultra Pink */
		else if (colorName == "razzle_dazzle_rose") cA = newArray(238, 52, 210);	/* #EE34D2 */
		else if (colorName == "hot_magenta") cA = newArray(255, 0, 204);			/* #FF00CC AKA Purple Pizzazz */
		else if (colorName == "outrageous_orange") cA = newArray(255, 96, 55);		/* #FF6037 */
		else if (colorName == "supernova_orange") cA = newArray(255, 191, 63);		/* FFBF3F Supernova Neon Orange*/
		else if (colorName == "sunglow") cA = newArray(255, 204, 51);				/* #FFCC33 */
		else if (colorName == "neon_carrot") cA = newArray(255, 153, 51);			/* #FF9933 */
		else if (colorName == "atomic_tangerine") cA = newArray(255, 153, 102);		/* #FF9966 */
		else if (colorName == "laser_lemon") cA = newArray(255, 255, 102);			/* #FFFF66 "Unmellow Yellow" */
		else if (colorName == "electric_lime") cA = newArray(204, 255, 0);			/* #CCFF00 */
		else if (colorName == "screamin'_green") cA = newArray(102, 255, 102);		/* #66FF66 */
		else if (colorName == "magic_mint") cA = newArray(170, 240, 209);			/* #AAF0D1 */
		else if (colorName == "blizzard_blue") cA = newArray(80, 191, 230);		/* #50BFE6 Malibu */
		else if (colorName == "dodger_blue") cA = newArray(9, 159, 255);			/* #099FFF Dodger Neon Blue */
		else IJ.log(colorName + " not found in " + functionL + ": Color defaulted to white");
		return cA;
	}
	function getHexColorFromColorName(colorNameString) {
		/* v231207: Uses IJ String.pad instead of function: pad */
		colorArray = getColorArrayFromColorName(colorNameString);
		 r = toHex(colorArray[0]); g = toHex(colorArray[1]); b = toHex(colorArray[2]);
		 hexName= "#" + "" + String.pad(r, 2) + "" + String.pad(g, 2) + "" + String.pad(b, 2);
		 return hexName;
	}	