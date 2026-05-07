# asc-ImageJ-ROI_Utilities

<h2>A collection of ROI utilities for ImageJ/Fiji</h2>

<p>
These are
<a href="https://imagej.net/">ImageJ</a> /
<a href="https://fiji.sc/">Fiji</a>
macros that do some useful things with ROIs:
</p>

<h3 id = "CreateROIGrid">Create a Grid of ROIs from a Single Selection</h3>
<p>
Creates a square grid of ROIs that are identical to the current selection.<br>
The original purpose was to create ROIs for scanned 35&nbsp;mm film strips.
</p>

<h3 id = "CreateUniformOverlaysFromROIs">Create Overlays of the Same Style for each ROI</h3>
<p>
Forces all overlays to have the same style.
</p>

<h3 id = "CreateTransparentOverlayFromROI">Create a Transparent Overlay for the Selected ROI</h3>
<p>
Creates a transparent overlay from the selected ROI.
</p>

<h3 id = "ExportAllROIsAsImageFiles">Export all ROIs as Individual Image Files</h3>
<p>
Exports all ROIs as individual image files. An expanded region around the ROIs can also be included for context and the region size can be set to the same values for all ROI-clips. The menu below shows the current options.
</p>

<img src="/images/Export_all_ROIs+as_ImageFiles_v260427_MenuEd_573x743.png" width=480 alt="Example of Export all ROIs as Individual Image Files macro">

<h3 id = "ExportROIsInSelectedArea">Export all ROIs in a Selected Area</h3>
<p>
Exports a collection of ROIs based on the selected area.
</p>

<h3 id = "SetROIColorandTransparency">Set ROI Color and Transparency</h3>
<p>
Opens up a dialog similar to the built-in ROI properties dialog but adding drop-downs for fill and stroke color selection and sliders for transparency.
</p>
	<img src="/images/ROI-Set_Color-Transp_Before-After_768x282.jpg" alt="Example showing use of Set ROI Color and Transparency macro to apply a semi-transparent color to an ROI" width=768>

<h3 id = "SortROIsByProximity">Sort ROI Set by Proximity to Current ROI Set</h3>
<p>
Sorts an archived ROI set by proximity to the current ROI set.
</p>

<h3 id = "SortROIsToGrid">Sort ROIs to a Rectangular Grid</h3>
<p>
The original order of objects (and ROIs) is by a top-to-bottom, left-to-right scan and if you have x,y grid of analysis points this may not exactly match the intuitive column/row order you would expect. You can use this macro to sort the ROIs of a rectangular grid into column-by-column, row-by-row order. This is particularly useful when combining with the export ROIs as image files macro above so that montaging the ROIs back into the same grid pattern respects the original arrangement. This macro was created to handle grids of microhardness indents.
</p>

<p>
<em>Requirement</em>: The rows must not overlap with each other and ROIs are already in the top-left:bottom-right order that would be expected from <em>Analyze Particles</em>.
</p>

<ul>
  <li>Sorts ROIs</li>
  <li>Adds row and column numbers to ROI name</li>
  <li>Appends original ROI name to final ROI name for reference</li>
  <li>Option to add ROI names to re-measured Results Table</li>
 </ul> 
  <p><img src="images/Sort_ROIs_by_Grid_v260429_Options_412x336_PAL64.png"
  alt="Grid options for Sort_ROIs_by_Grid macro" width=360></p>

<hr>

<p><strong><sub><sup>Legal Notice:</sub</sup></strong></p>

<p><sub><sup>
These macros have been developed to demonstrate the power of the ImageJ macro language
and we assume no responsibility whatsoever for their use by other parties, and make no
guarantees, expressed or implied, about their quality, reliability, or any other
characteristic. On the other hand, we hope you do have fun with them without causing harm.
</sub</sup></p>

<p><sub><sup>
The macros are continually being tweaked and new features and options are frequently
added, meaning that not all of these are fully tested. Please contact me if you have any
problems, questions, or requests for new modifications.
</sub</sup></p>

</body>
</html>