# biofilm-wavefront-tracking


Background: 
Images of a bacterial biofilm were acquired in the Gahlmann lab using a phase contrast microscope
over a period of a day. Image timepoints were acquired every hour.

Input: Video stack compiled as a movie.
Output: Video stack with biofilm wavefront annotation.

Method:
Performs texture segmentation using a manually defined Gabor filterbank.
Uses morphological image processing and image statistics to find biofilm edge.

TODO:
"Noisy" boundary handling
Graph wavefront position, extract growth rate
