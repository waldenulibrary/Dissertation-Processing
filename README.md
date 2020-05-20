# Dissertation-Processing
Scripts for batch processing ProQuest dissertation/theses XML metadata for batch upload to Digital Commons.

## Installation
1. Determine where the dissertation PDF files will be uploaded for batch processing. This needs to be a publicly facing server that can be accessed by Digital Common's batch process without authentication. The URL for the server directory will need to be added to the XSLT below.

1. The DissPrep.bat file relies on 7-zip to batch unzip the zip files. If using a different program or if program is located in another directory, update the file path in the batch file.

1. The following tags need to be updated in the PQ-DC-tranform.xslt file:
    * < institution >: update to your institution's name
    * < disciplines >: add/remove disciplines your institution uses
    * < fulltext-url >: add your public server URL where the PDFs will be temporarily stored for batch upload
    * < degree_name >: update/add degrees for your institution

## Metadata processing
1. Download all zip files from ProQuest's servers to the downloadedFiles folder.

1. Run DissPrep.bat file. A new file called CombinedXML.xml will be created in the same directory.

1. Using the PQ-DC-tranform.xslt file and an XSLT v2.0 transformer, such as Oxygen XML Editor, transform the CombinedXML.xml file. This will crosswalk the ProQuest's metadata to Digital Common's metadata schema. Save the transformed file as "CombinedXML_uploadready.xml"

1. Review the the tranformed XML file for any issues with the metadata including special characters.

1. Upload all the PDFs in the downloadedFiles folder to your public server location (e.g. Azure Blob).

1. Submit the "CombinedXML_uploadready.xml" via Digital Commons' Batch Upload URL tool.

1. Once Digital Commons has confirmed the upload was processed, run the Cleanup.bat file to remove all dissertation files from the folder directory on your local computer.

