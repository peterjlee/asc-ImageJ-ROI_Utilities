# asc-ImageJ-ROI_Utilities
A collection of ROI utilities for ImageJ/Fiji
## ROI utilities for ImageJ/Fiji</h3>
<p>These are ImageJ[ImageJ homepage](https://imagej.net/) /Fiji[Fiji homepage](https://fiji.sc/) macros that do some useful things with ROIs:
## Create_grid_of_ROIs_from_single_selection:
Creates a square grid of ROIs that are identical to the current selection
Original purpose was to create ROIs for scanned 35 mm film strips.
## Create_same_style_Overlays_for_each_ROI:
Forces all overlays to have the same style.
## Create_Transparent_Overlay_for_Selected_ROI:
Creates a transparent overlays_from the selected ROI.
##Export_all_ROIs_as_ImageFiles:
Optionally draws the Feret axes on the selected image.
![Example of Export_all_ROIs+as_ImageFiles_v260427_MenuU](/images/Export_all_ROIs+as_ImageFiles_v260427_MenuEd_573x743.png)
## Export_ROIs_in_Selected_Area:
Exports a collection of ROIs based on the selected area
## ROI_set_Color_and_Transparency:
Sets the ROI color and transparency
## Sort_ROI_set_by_Proximity_to_Current_ROI_set:
Sorts an archived ROI set by proximity to the current ROI set
## Sort_ROIs_by_Grid:
Sorts ROIs of a rectangular grid into row/column order
Created for automatically created grids of microhardness indents so subsequent ROI montages are in the expected row/column order.
Requires that rows do not overlap and ROIS are already in xy order as would be expected from *Analyze Particles*
- Sorts ROIs 
- Adds row and column numbers to ROI name
- Appends original ROI name to final ROI name for reference.
- Option to add ROI names to re-measured Results Table

~**Legal Notice:**
These macros have been developed to demonstrate the power of the ImageJ macro language and we assume no responsibility whatsoever for its use by other parties, and make no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. On the other hand we hope you do have fun with them without causing harm.

The macros are continually being tweaked and new features and options are frequently added, meaning that not all of these are fully tested. Please contact me if you have any problems, questions or requests for new modifications.~
