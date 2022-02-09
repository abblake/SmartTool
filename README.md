# SMART Dynamic Strategy Tool

**Welcome to SMART Github page!**  
Our intention in creating this Github page is to enable users to provide feedback about the SMART Tool. This includes but is not limited to additional variables, reporting known database issues, and/or reporting issues with the tool itself. Additionally, this Github page provides the R scripts for everything we use in the implementation  of the tool.   

  
Thank you!  
-Andrew, Oleg, Tim, and Aaron

## Contact the Authors/Contribute Code and/or Data To Improve the Tool
Do you like this tool? Do you have some code or data that can make it better? While the underlying code of this tool is R, we can collaborate to port code from Stata, SAS, etc. into this platform. Please contact our developer [Andrew](mailto:abblake@uark.edu) or create a new post on the "Issues" tab to 

## Dontate to SMART
To help offset costs with maintaining the SMART tool, we established a donation page through Paypal. Every dollar truly helps, thank you.
[Click here to donate](https://www.paypal.com/donate/?hosted_button_id=77YGYJJURM2A2)

**Notes on output:**  
The script will output two files. One file is a large dataset that includes ALL variables from the WRDS databases accessed. The second file will end with **_small** which includes the variables selected, firm information, and date information only.


## **DISCLAIMER**  
While the goal of this project is to standardize the data collection process for management students and scholars, the reality is that these archival datasets and methods for calculating some variables are not perfect. Below we list the known issues we are aware of as a word of caution. We also hope that you (the user or collaborator) can tell us about additional issues you've found in the data, suggest possible solutions, or provide patches to the data (even a single line!). 

1. The CEOANN flag which indicates the executive is the CEO is sometimes blank or inaccurate.
2. The method for identifying CEO duality can sometimes be inaccurate (about 4% based on a sample of 2910 manually coded CEO duality variables). We are working on a method for flagging these for manual correction.
3. Duplicate records are removed using the gvkey and year variables (all databases). 
4. Sometimes SICH codes are missing from Compustat. When missing, we replace NA with the "SIC" code variable found in the *company* WRDS/Compustat database.
5. The firm age variable is based on ipodate. Sometimes this causes negative firm_age.
