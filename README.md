KARAJ
==================================

## A command-line software to streamline acquiring biological data



------------------------------------------------------------------------------------------------------------------------

## Table of Contents

- [Installation](#installation)
- [KARAJ analysis workflow](#KARAJ-analysis-workflow)
- [Arguments](#arguments)
- [How to use](#how-to-use)
- [Reference](#reference)
- [Author Info](#author-info)
- [Acknowledgements](#Acknowledgements)
- [License](#license)

------------------------------------------------------------------------------------------------------------------------

## Installation

KARAJ runs on LINUX. Install the package from Github using the following commands.

```
cd /KARAJ
git clone https://github.com/Knowledge-Wisdom-Understanding/Auto-Recon.git
cd Auto-Recon
chmod +x setup.sh
./setup.sh
```
Alternatively, the package may downloaded from apt:
```

------------------------------------------------------------------------------------------------------------------------

## KARAJ analysis workflow
## Required Arguments

| Argument | Description | Default |
| :---: | :---: | :---: | 
| -l | The list of URL(s) | empty |
| -p	| The list of PMCID(s) | empty | 
| -o	| The output working directory | The current working directory | 
| -t	| The list of PMCID(s) | empty | 
| -p	| The list of PMCID(s) | empty | 
| -p	| The list of PMCID(s) | empty | 
| -p	| The list of PMCID(s) | empty | 
| -p	| The list of PMCID(s) | empty | 

------------------------------------------------------------------------------------------------------------------------

## Required Arguments


------------------------------------------------------------------------------------------------------------------------

## How to use

By default, PeakCNV runs in the current working directory unless specified by the user. By default, results will be saved in the working directory.  In clustering step, for each chromosome, PeakCNV asks you the eps value based on the k nearest neighbors(knn) plot. The optimal value is an elbow, where a sharp change in the distance occurs. For more information about results see the https://mahdieh1.github.io/PeakCNV/.
```
library("PeakCNV")
PeakCNV()
```
Download the test data sets from https://github.com/mahdieh1/PeakCNV/tree/main/test-data into your working directory. For this datasets, P-value i

#### Input files ####
1. Case CNVs (case.bed):

| Chr | Start | End | Sample-Id |
| :---: | :---: | :---: | :---: |
| 1 | 6742281 | 6742903 | SP7890 |

2. Control CNVs (control.bed):

| Chr | Start | End | Sample-Id |
| :---: | :---: | :---: | :---: |
| 1 | 6742281 | 6742903 | sa321 |

Please put input files (case.bed and control.bed) in the working directory. If your CNV list contains chr X or Y, please replace them with 23,24.

#### Output files: ####

1. CNVRs (CNVRs.bed):

| Chr | Start | End | 
| :---: | :---: | :---: |
| 1 | 6742281 | 6742903 | 

2. clustered CNVRs (clustering.txt):

| Chr | Start | End | #case | Cluster-NO |
| :---: | :---: | :---: | :---: | :---: |  
| 1 | 6742281 | 6742903 | 15 | 1 |

3. Selected CNVRs (selection.txt)

| Score | #chr | Start | End | #case | Cluster-NO | 
| :---: | :---: | :---: | :---: | :---: | :---: | 
| 56 | 21 | 6742281 | 6742903 | 15 |	225.86 | 0 |

------------------------------------------------------------------------------------------------------------------------

## Reference
```
Please consider citing the follow paper when you use this code.
  Title={KARAJ: a command-line software to streamline acquiring biological data},
  Authors={Mahdieh Labani, Amin Beheshti, Nigel Lovell, Hamid Alinejad-Rokny, Ali Afrasiabi}
}
```
------------------------------------------------------------------------------------------------------------------------

## Contacts

I will be pleased to address any question or concern about the PeakCNV package:
In case of queries, please email: mahdieh.labani@students.mq.edu.au

------------------------------------------------------------------------------------------------------------------------

### People who contributed to the KARAJ idea and code:
* Mahdieh Labani 
* Ali Afrasiabi
* Amin Beheshti
* Hamid Alinejad-Rokny
* Nigel Lovell

------------------------------------------------------------------------------------------------------------------------

## Acknowledgements
This work was funded by the UNSW Scientia Program Fellowship and the Australian Research Council Discovery Early Career Researcher Award (DECRA), Macquarie PhD Scholarship and Australian Government Research Training Program (RTP) scholarship. Analyses were made possible with High Performance Computing resources provided by the BioMedical Machine Learning Lab with funding from the Australian Government and the UNSW SYDNEY.

------------------------------------------------------------------------------------------------------------------------

## License

This package is free software; you can redistribute it and/or modify it under the terms of the , MIT License as published by the Free Software Foundation.


