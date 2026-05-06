# asc-ImageJ-ROI_Utilities

<h2>A collection of ROI utilities for ImageJ/Fiji</h2>

<p>
These are
<a href="https://imagej.net/">ImageJ</a> /
<a href="https://fiji.sc/">Fiji</a>
macros that do some useful things with ROIs:
</p>

<h3>Create_grid_of_ROIs_from_single_selection</h3>
<p>
Creates a square grid of ROIs that are identical to the current selection.<br>
Original purpose was to create ROIs for scanned 35&nbsp;mm film strips.
</p>

<h3>Create_same_style_Overlays_for_each_ROI</h3>
<p>
Forces all overlays to have the same style.
</p>

<h3>Create_Transparent_Overlay_for_Selected_ROI</h3>
<p>
Creates a transparent overlay from the selected ROI.
</p>

<h3>Export_all_ROIs_as_ImageFiles</h3>
<p>
Exports all ROIs as individual image files. An expanded region our the ROIs can also be included for context and the region size can be set to the same values for all ROIs-clips. The menu below shows the current options.
</p>

<img
  src="/images/Export_all_ROIs+as_ImageFiles_v260427_MenuEd_573x743.png"
  alt="Example of Export_all_ROIs as ImageFiles">

<h3>Export_ROIs_in_Selected_Area</h3>
<p>
Exports a collection of ROIs based on the selected area.
</p>

<h3>ROI_set_Color_and_Transparency</h3>
<p>
Sets the ROI color and transparency.
</p>

<h3>Sort_ROI_set_by_Proximity_to_Current_ROI_set</h3>
<p>
Sorts an archived ROI set by proximity to the current ROI set.
</p>

<h3>Sort_ROIs_by_Grid</h3>
<p>
Sorts ROIs of a rectangular grid into row/column order.
</p>

<p>
Created for automatically created grids of microhardness indents so subsequent ROI
montages are in the expected row/column order.
</p>

<p>
Requires that rows do not overlap and ROIs are already in xy order as would be
expected from <em>Analyze Particles</em>.
</p>

<ul>
  <li>Sorts ROIs</li>
  <li>Adds row and column numbers to ROI name</li>
  <li>Appends original ROI name to final ROI name for reference</li>
  <li>Option to add ROI names to re-measured Results Table</li>
</ul>

<hr>

<p><strong><sub<sup>Legal Notice:</strong></p>

<p>
These macros have been developed to demonstrate the power of the ImageJ macro language
and we assume no responsibility whatsoever for their use by other parties, and make no
guarantees, expressed or implied, about their quality, reliability, or any other
characteristic. On the other hand, we hope you do have fun with them without causing harm.
</p>

<p>
The macros are continually being tweaked and new features and options are frequently
added, meaning that not all of these are fully tested. Please contact me if you have any
problems, questions, or requests for new modifications.</sub</sup>
</p>

</body>
</html>