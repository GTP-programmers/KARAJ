#!/bin/bash
##########################################################################################################################################################################################
#							KARAJ:      a command-line software to automate and streamline acquiring biological data       					#
#   							Version:    v1.0								                  					#
#							About:      Developed in the BioMedical Machine Learning Lab, University of New South Wales.   					#
#							Developers: Mahdieh Labani (co-developer) and Ali Afrasiabi (Co-developer).                    					#
##########################################################################################################################################################################################



#*********************************************************************************FUNCTION checkInstallation******************************************************************************
# 								This function checks installation process and prints a message								# ##########################################################################################################################################################################################																								
# Function name:																						#
#              checkInstallation																				#
# ARGUMENTS: 																							#
# 		None																						#
# OUTPUTS: 																							#
# 		Writes String to STDOUT																			#
# RETURN: 																							#
# 		0 if success: prints "KARAJ v1.0 is ready to go", otherwise "KARAJ is fiald to progress. KARAJ may not be installed properly. Please run the installer.".			#
#*****************************************************************************************************************************************************************************************

	function checkInstallation 
		{
			pkg1=(aspera)
			is_aspera_installed=$(~/."$pkg1"/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect version") 
			pkg2=(ffq)
			is_ffq_installed=$("$pkg2" -h | grep -Eo '^usage: ffq')
			pkg3=(lynx)
			is_lynx_installed=$(dpkg-query -s "$pkg3" 2>/dev/null | grep "install ok installed") 
			pkg4=(ncbi-entrez-direct)
			is_ncbi_installed=$(dpkg-query -s "$pkg4" 2>/dev/null | grep "install ok installed") 

			if [[ "${is_aspera_installed}" == "Aspera Connect version" && "${is_ffq_installed}" == 'usage: ffq' && \
			"${is_ncbi_installed}" == "Status: install ok installed" && "${is_lynx_installed}" == "Status: install ok installed" ]]; then
					echo ""
					echo "KARAJ v1.0 is ready to go."
					echo ""
				else
					echo 
					echo  "KARAJ is fiald to progress. KARAJ may not be installed properly. Please run the installer."
					echo 
			fi 
	   	 }
   
#*********************************************************************************FUNCTION usage*****************************************************************************************
# 							This function prints a help message describing all the KARAJ's command-line options							#	 ##########################################################################################################################################################################################																								
# Function name:																						#
#              usage																						#
# ARGUMENTS: 																							#
# 		None																						#
# OUTPUTS: 																							#
# 		Writes String to STDOUT																			#
# RETURN: 																							#
# 		DESCRIPTION OF FLAGS																				#
#*****************************************************************************************************************************************************************************************  
	
	function usage 
		{
			echo ""
			echo "KARAJ:      a command-line software to automate and streamline acquiring biological data"
			echo "Version:    v1.0"
			echo "About:      developed in the BioMedical Machine Learning Lab, University of New South Wales."
			echo "Developers: Mahdieh Labani (co-developer) and Ali Afrasiabi (Co-developer)."
			echo "Code:       https://github.com/mahdieh1/KARAJ"
			echo "Email:      m.labani@unsw.edu.au and a.afrasiabi@unsw.edu.au"
			echo "Citation:"
			echo "Labani M & Afrasiabi A et al, a command-line software to automate and streamline acquiring biological data" 
			echo ""
			echo "Instuction: the list of operations and options that are supported by KARAJ"
			echo ""
			echo "    -l                 list of URL(s), please see exmaples (usage examples -u) or github for further explanation."
			echo "    -p                 list of PMCID(s), please see exmaples (usage examples -u) or github for further explanation."
			echo "    -o                 Output working directory."
			echo "    -t                 type of files: bam/vcf/fastq, please see exmaples (usage examples -u) or github for further explanation."
			echo "    -s                 obtaining suplemenatry data of the corresponding study/studies by specifiying value 1. defult value is 0, which disables the operation."
			echo "    -f                 downloading list of PMCIDs, URLs or accession numbers by passing values 1, 2 and 3, repecteivly."
			echo "                       please see exmaples (usage examples -u) or github for further explanation."
			echo "    -i                 accession number(s): PRJNA/SRP/ERP/GSE/SRR/SRA/SRX/SRS/ERX/ERS/ERP/DRR/DRS/DRX/DRP/GSM/ENCSR/ENCSB/ENCSD/CXR/SAMN."
			echo "    -d                 defualt value is 0 which means downloading data for all accession numbers obtained from URL(s) or PMCID(s)."
			echo "                       by passing value 1 user can select accession numbers to download later on by the summary result."
			echo "    -m                 obtaining metadata table containing sample information and experimental design of the corresponding study."
			echo "    -h                 help."
			echo "    -u                 usage examples."
			echo "    -j                 number of cores."
			echo "    -n                 obtaining processed data of the corresponding study/studies by specifying value 1. de-fault value is 0, which disables the operation."

			exit 1
		}
	
#*********************************************************************************FUNCTION Example****************************************************************************************
# 									This function prints 3 KARAJ commands examples									#	##########################################################################################################################################################################################																								
# Function name:																						#
#              Example																						#
# ARGUMENTS: 																							#
# 		None																						#
# OUTPUTS: 																							#
# 		Writes String to STDOUT																			#
# RETURN: 																							#
# 		Examples of KARAJ commands																			#
#*****************************************************************************************************************************************************************************************  	
    
     function Example
		{
		 echo "Example of how to use KARAJ.
		 *********************************
		 Example1:
		 Example2:
		 Example3:"
		}
	
#*********************************************************************************FUNCTION getopts-extra**********************************************************************************
# 									This function fills an array with the input values									#	 ##########################################################################################################################################################################################																								
# Function name:																						#
#              getopts-extra																					#
# ARGUMENTS: 																							#
# 		input values 																					#
# OUTPUTS: 																							#
# 		OPTARG array																					#
# RETURN: 																							#
# 		OPTARG array																					#
#*****************************************************************************************************************************************************************************************  	
     
      function getopts-extra() 
		{
			declare i=1
			while [[ ${OPTIND} -le $# && ${!OPTIND:0:1} != '-' ]]; do
				OPTARG[i]=${!OPTIND}
				let i++ OPTIND++
			done
		}

## specifying the options
while getopts ":l:p:d:o:t:s:f:i:m:u:h:j:n" opt; do
 	 case ${opt} in
		    l)
		      getopts-extra "$@"
		      link=( "${OPTARG[@]}" )
		      checkInstallation
		      ;;
      
		    p)
		      getopts-extra "$@"
		      PMCID=( "${OPTARG[@]}" )
		      checkInstallation
		      ;;
       
		    d)
	              down="$OPTARG"
		      ;;
   
		    o)
		      Output="$OPTARG"
		      ;;
 
		    t)
		      type="$OPTARG"
		      ;; 
		      
		    s)
		      supp="$OPTARG"
		      ;; 
		      
		    f)
		      file="$OPTARG"
		      checkInstallation
		      ;; 
		      
		    i)
		    
		      getopts-extra "$@"
		      ID=( "${OPTARG[@]}" )
		      checkInstallation
		      ;; 
		      
		    m)
		      meta="$OPTARG"
		      ;; 
		  
		    u)
		      Example
		      exit 0
		      ;; 
		      
		    h)
		      usage
		      exit 0
		      ;; 
		      
		    j)
		      core="$OPTARG"
		      ;;  
		    
		    n)
		      processed="$OPTARG"
		      ;;   
		       
		    \?)
		      echo "Invalid option, please see the Help using -h option:" >&2
		      exit 0
		      ;;
		      
		    \:) 
		      printf "Argument missing from -%s option\n" $OPTARG 
		      exit 0
		      ;;
   
  	esac
done
shift $((OPTIND -1))

## input check for mandatory options
if [[ ! $link && ! $PMCID && ! $file  && ! $ID  ]]; then
	echo "You missed one othe obligatory arguments">&2
	echo "one of these options must be sepcified -p, -l, -f or -i">&2
	exit 0
fi

if [[  "$link" && "$PMCID" ]]
	then
	echo "Two obligatory flags are used with each other. Please enter one of these flagss.">&2
	exit 0
	elif [[  $file  &&  $ID ]]
	then
	echo "Two obligatory flags are used with each other. Please enter one of these flagss. ">&2
	exit 0
	elif [[  $link  &&  $ID ]]
	then
	echo "Two obligatory flags are used with each other. Please enter one of these flagss. ">&2
	exit 0
	elif [[  $link  &&  $file ]]
	then
	echo "Two obligatory flags are used with each other. Please enter one of these flagss.">&2
	exit 0
	elif [[  $PMCID  &&  $file ]]
	then
	echo "Two obligatory flags are used with each other. Please enter one of these flagss. ">&2
	exit 0
fi

## specifying output directory
if [[ -v Output ]];
	then
	    echo "*******************************"
	    echo "The specified output directory is:"
	    echo $Output
	    echo "*******************************"
	    echo ""
	    out=$Output
	    cd $Output
	else
	    echo "*******************************"
	    echo "Output directory is not specified"
	    echo "the current working directory" """ $PWD """ "will be used as output directory"
	    echo "*******************************"
	    echo ""
	    out=$PWD
	    
fi


## making URL(s) from PMCID(s)
if [[ -v PMCID ]];
	then
		for j in "${!PMCID[@]}"; do
		l="https://www.ncbi.nlm.nih.gov/pmc/articles/${PMCID[j]}/"
		echo $l >> PMCIDlist
		cat PMCIDlist | sort | uniq > tmp && mv tmp PMCIDlist

        done 
		## obtaining supplementary tables using PMCID
		if [[ -v supp ]];
			then  
				if [[ $supp == '1' ]];then
					
					for p in $(cat PMCIDlist);do
				
						lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
						lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
						Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
						mkdir "${out}"/"${Z}"
						
							for s in $(cat supp1); do
						
								dir=$(echo ~)
								axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
								
							done
					done
		        		exit 0
				fi
			else
				for p in $(cat PMCIDlist);do
				
					lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
			      	 	lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
					Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
					mkdir "${out}"/"${Z}"
					
						for s in $(cat supp1); do
					
							dir=$(echo ~)
							axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
					
						done
				done
	
  	  	fi

## searching for different types of accession numbers in the text of articles that are obtained using genrated URL(s)   
	Types=("GSE" "PRJNA" "ERP" "SRP")
		touch info.txt
		for k in $(cat PMCIDlist);do
		
			printf '%s\n' ${k} > file.txt
				lynx -dump ${k} | grep -Eo "PMID: \[.*\][0-9]{1,20}" | sed -e 's/.*]//g' > PMID
			   	PMID=$(cat PMID)
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^TI/,/^PG/{{ /^PG/! p } }' | sed "s|TI  - |      |g" | sed 's/^[ \t]*//' | tr '\n' ' ' > t2
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AB/,/^FAU /{{ /^FAU /! p } }' | sed "s|AB  - |      |g" | sed 's/^[ \t]*//' | grep -v "CI  - " | tr '\n' ' ' > t3
				
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AU/,/^AD/{{ /^AD/! p } }' | sed "s|AU  - |      |g" | sed 's/^[ \t]*//' | grep -v "AUID- " | tr '\n' ';' > t4
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^PMID/,/^OWN/{{ /^OWN/! p } }' | sed "s|PMID- |PMID:|g" | sed 's/^[ \t]*//' > t5
				
				paste -d"|" t2 t3 t4 t5 > tmp2
				rm t2
				rm t3
				rm t4
				rm t5
				rm PMID
			touch list
			M=$(cat list | wc -l)

				for i in "${Types[@]}"; do
					
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq >> list
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq > list22
				 	awk '
						{ 
						    for (i=1; i<=NF; i++)  {
						        a[NR,i] = $i
						    }
						}
						NF>p { p = NF }
						END {    
    						for(j=1; j<=p; j++) {
						        str=a[1,j]
						        for(i=2; i<=NR; i++){
						            str=str" "a[i,j];
						        }
						        print str
						    }
						}' list22 > file1.txt
					tr ' ' ';' < file1.txt > tmp1
					mv tmp1 file1.txt
					paste -d"|" file.txt file1.txt tmp2 > file2.txt 2> /dev/null
				 	cat info.txt file2.txt >> tmp1 && mv tmp1 info.txt
				 	cat info.txt | uniq > tmp1 && mv tmp1 info.txt
				 	cat info.txt | awk -F'|' '{print $1" | ",$2" | ",$3" | ",$4" | ",$5" | ",$6}' > tmp1 && mv tmp1 info.txt
				 	rm file1.txt
				 	rm file2.txt
				 	rm list22
				 	rm file.txt 2> /dev/null
				 	rm tmp2 2> /dev/null
				done
	      		
	      		N=$(cat list | wc -l)
	      		
	      			if [[ "${N}" == "${M}" ]];
					then
	      	     
						Z=$(echo ${k} | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
						echo "There is no accession number in the text of" "${Z}"
						echo ""
				fi

				cat list | sort | uniq > tmp && mv tmp list
     
     		done
     
				
     
		if [[ -z $(cat list) ]];
			then
			
				echo "There is no accession number in the text of" "${PMCID}"
				echo ""
				exit 0
		fi
		mapfile lines < list	
		
			
## generating metadata
if [[ -v meta ]]; 
	then
		if [[ $meta == '1' ]];
			then
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp1

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp2

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
				rm -rf "${out}"/"${B}"/"${B}"_tmp3

				paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

				rm -rf "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp33

				cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
				sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

				rm -rf "${out}"/"${B}"/"${B}"_tmp44
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
			done
			exit 0
		elif [[ $meta == '0' ]];
			then
				for idx in "${!lines[@]}";do

					B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
					X=$(echo "${B}" | rev | cut -c4- | rev)
					y=$(echo "${X}""nnn")
					l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
					mkdir "${out}"/"${B}" 
					wget -q -P "${out}"/"${B}" ""${l}""
					gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp1

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp2

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
					rm -rf "${out}"/"${B}"/"${B}"_tmp3

					paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

					rm -rf "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp33

					cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
					sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

					rm -rf "${out}"/"${B}"/"${B}"_tmp44
					rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
					done
		fi
fi		


## generating summary reports   
		echo "summary report:"
		echo ""
		mapfile lines < list
	
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				D=$(cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Series_overall_design' | sed 's/!Series_overall_design//g' | sed 's/^[ \t]*//' | sed 's/"//g')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				esearch -db gds -query "${B}" | efetch | grep '^1\.\|^2\.\|Platform:' | grep -v "Series:" | sed 's/2\. /Type: /' | sed 's/1\. /Description: /' > tmp
				echo "${C}".  "${B}"> tmp1
				sed -i 's/^[ \t]*//' tmp1
				echo "Overall experiment desgin"":" "${D}" > tmp2
				cat tmp | grep "Description: " > tmp3
				cat tmp | grep "Type: " > tmp4
				cat tmp | grep -Eo '[0-9]{1,10} Samples' | sed 's/^[ \t]*//' > tmp5
				echo "##############################################" > tmp6
				cat tmp1 tmp2 tmp3 tmp4 tmp5 tmp6
				rm tmp1
				rm tmp2
				rm tmp3
				rm tmp4
				rm tmp5
				rm tmp6
				rm tmp
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
                
			done
						
			echo ""
			echo "##############################################" 
			echo  $(cat list) "specified to download"
			echo "##############################################" 
			echo ""
			cp list list1
			
fi        
	
## searching for different types of accession numbers in the text of articles that are obtained by user specified URL(s)   
if [[ -v link ]];
	then
		for j in "${!link[@]}"; do

			echo ${link[j]} >> PMCIDlist

		done
	
		cat PMCIDlist | sort | uniq > tmp && mv tmp PMCIDlist
		cp PMCIDlist list1
		echo "$PMCIDlist"		
	
			if [[ -v supp ]];
				then
					if [[ $supp == '1' ]];
						then
							for p in $(cat PMCIDlist);do
               
								lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
								lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
								Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
								mkdir "${out}"/"${Z}"
									for s in $(cat supp1); do
		
										dir=$(echo ~)
										axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
									
									done
							done
							exit 0
					fi
			else
	
				for p in $(cat PMCIDlist);do
         
					lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
					lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
					Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
					mkdir "${out}"/"${Z}"
						for s in $(cat supp1); do

							dir=$(echo ~)
							axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"

						done
				done
	
			fi
		
	Types=("GSE" "PRJNA" "ERP" "SRP")
	
		touch info.txt
		for k in $(cat PMCIDlist);do
		
			printf '%s\n' ${k} > file.txt
				lynx -dump ${k} | grep -Eo "PMID: \[.*\][0-9]{1,20}" | sed -e 's/.*]//g' > PMID
			   	PMID=$(cat PMID)
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^TI/,/^PG/{{ /^PG/! p } }' | sed "s|TI  - |      |g" | sed 's/^[ \t]*//' | tr '\n' ' ' > t2
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AB/,/^FAU /{{ /^FAU /! p } }' | sed "s|AB  - |      |g" | sed 's/^[ \t]*//' | grep -v "CI  - " | tr '\n' ' ' > t3
				
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AU/,/^AD/{{ /^AD/! p } }' | sed "s|AU  - |      |g" | sed 's/^[ \t]*//' | grep -v "AUID- " | tr '\n' ';' > t4
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^PMID/,/^OWN/{{ /^OWN/! p } }' | sed "s|PMID- |PMID:|g" | sed 's/^[ \t]*//' > t5
				
				paste -d"|" t2 t3 t4 t5 > tmp2
				rm t2
				rm t3
				rm t4
				rm t5
			touch list
			M=$(cat list | wc -l)

				for i in "${Types[@]}"; do
					
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq >> list
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq > list22
				 	awk '
						{ 
						    for (i=1; i<=NF; i++)  {
						        a[NR,i] = $i
						    }
						}
						NF>p { p = NF }
						END {    
    						for(j=1; j<=p; j++) {
						        str=a[1,j]
						        for(i=2; i<=NR; i++){
						            str=str" "a[i,j];
						        }
						        print str
						    }
						}' list22 > file1.txt
					tr ' ' ';' < file1.txt > tmp1
					mv tmp1 file1.txt
					paste -d"|" file.txt file1.txt tmp2 > file2.txt 2> /dev/null
				 	cat info.txt file2.txt >> tmp1 && mv tmp1 info.txt
				 	cat info.txt | uniq > tmp1 && mv tmp1 info.txt
				 	cat info.txt | awk -F'|' '{print $1" | ",$2" | ",$3" | ",$4" | ",$5" | ",$6}' > tmp1 && mv tmp1 info.txt
				 	rm file1.txt
				 	rm file2.txt
				 	rm list22
				 	rm file.txt 2> /dev/null 
				 	rm tmp2 2> /dev/null
				done
	
	
		
			N=$(cat list | wc -l)
			
			if [[ "${N}" == "${M}" ]];
				then
					Z=$(echo ${k} | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
					echo "There is no accession number in the text of" "${Z}"
					echo ""
			fi
			cat list | sort | uniq > tmp && mv tmp list
	
		done
     

## generating metadata
mapfile lines < list
if [[ -v meta ]]; 
	then
		if [[ $meta == '1' ]];
			then
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp1

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp2

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
				rm -rf "${out}"/"${B}"/"${B}"_tmp3

				paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

				rm -rf "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp33

				cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
				sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

				rm -rf "${out}"/"${B}"/"${B}"_tmp44
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
			done
			exit 0
			
		elif [[ $meta == '0' ]];
			then
				for idx in "${!lines[@]}";do

					B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
					X=$(echo "${B}" | rev | cut -c4- | rev)
					y=$(echo "${X}""nnn")
					l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
					mkdir "${out}"/"${B}" 
					wget -q -P "${out}"/"${B}" ""${l}""
					gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp1

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp2

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
					rm -rf "${out}"/"${B}"/"${B}"_tmp3

					paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

					rm -rf "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp33

					cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
					sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

					rm -rf "${out}"/"${B}"/"${B}"_tmp44
					rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
					done
	fi
fi		

## generating summary reports
		echo "summary report:"
		echo ""
		mapfile lines < list
	
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				D=$(cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Series_overall_design' | sed 's/!Series_overall_design//g' | sed 's/^[ \t]*//' | sed 's/"//g')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				esearch -db gds -query "${B}" | efetch | grep '^1\.\|^2\.\|Platform:' | grep -v "Series:" | sed 's/2\. /Type: /' | sed 's/1\. /Description: /' > tmp
				echo "${C}".  "${B}"> tmp1
				sed -i 's/^[ \t]*//' tmp1
				echo "Overall experiment desgin"":" "${D}" > tmp2
				cat tmp | grep "Description: " > tmp3
				cat tmp | grep "Type: " > tmp4
				cat tmp | grep -Eo '[0-9]{1,10} Samples' | sed 's/^[ \t]*//' > tmp5
				echo "##############################################" > tmp6
				cat tmp1 tmp2 tmp3 tmp4 tmp5 tmp6
				rm tmp1
				rm tmp2
				rm tmp3
				rm tmp4
				rm tmp5
				rm tmp6
				rm tmp
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt

			done
						
			echo ""
			echo "##############################################" 
			echo  $(cat list) "specified to download"
			echo "##############################################" 
			echo ""
			cp list list1
			
fi

## searching for different types of accession numbers in the text of articles using list of PMCIDs, accession numbers or URLs that are specified by user
if [[ -v file ]];
	then
		if [[ $file == '1' ]];
			then
				cp PMCID.txt PMCID
				for j in $(cat "${out}"/PMCID);do
					
					l="https://www.ncbi.nlm.nih.gov/pmc/articles/${j}/"
					echo $l >> PMCIDlist
					cat PMCIDlist | sort | uniq > tmp && mv tmp PMCIDlist
					
				done
    
				if [[ -v supp ]];
					then
						if [[ $supp == '1' ]];
							then
	       
		       					for p in $(cat PMCIDlist);do
									       
									lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
									lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
									Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
									mkdir "${out}"/"${Z}"
									
								for s in $(cat supp1); do
									dir=$(echo ~)
									axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
								done
								done
								exit 0
						fi
				else
								for p in $(cat PMCIDlist);do
									 
									lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
									lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
									Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
									mkdir "${out}"/"${Z}"
									
								for s in $(cat supp1); do
									dir=$(echo ~)
									axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
								done
								done
									
				fi
	Types=("GSE" "PRJNA" "ERP" "SRP")
		for k in $(cat PMCIDlist);do
			touch list
			M=$(cat list | wc -l)

				touch info.txt
		
			printf '%s\n' ${k} > file.txt
				lynx -dump ${k} | grep -Eo "PMID: \[.*\][0-9]{1,20}" | sed -e 's/.*]//g' > PMID
			   	PMID=$(cat PMID)
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^TI/,/^PG/{{ /^PG/! p } }' | sed "s|TI  - |      |g" | sed 's/^[ \t]*//' | tr '\n' ' ' > t2
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AB/,/^FAU /{{ /^FAU /! p } }' | sed "s|AB  - |      |g" | sed 's/^[ \t]*//' | grep -v "CI  - " | tr '\n' ' ' > t3
				
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AU/,/^AD/{{ /^AD/! p } }' | sed "s|AU  - |      |g" | sed 's/^[ \t]*//' | grep -v "AUID- " | tr '\n' ';' > t4
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^PMID/,/^OWN/{{ /^OWN/! p } }' | sed "s|PMID- |PMID:|g" | sed 's/^[ \t]*//' > t5
				
				paste -d"|" t2 t3 t4 t5 > tmp2
				rm t2
				rm t3
				rm t4
				rm t5
			touch list
			M=$(cat list | wc -l)

				for i in "${Types[@]}"; do
					
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq >> list
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq > list22
				 	awk '
						{ 
						    for (i=1; i<=NF; i++)  {
						        a[NR,i] = $i
						    }
						}
						NF>p { p = NF }
						END {    
    						for(j=1; j<=p; j++) {
						        str=a[1,j]
						        for(i=2; i<=NR; i++){
						            str=str" "a[i,j];
						        }
						        print str
						    }
						}' list22 > file1.txt
					tr ' ' ';' < file1.txt > tmp1
					mv tmp1 file1.txt
					paste -d"|" file.txt file1.txt tmp2 > file2.txt 2> /dev/null
				 	cat info.txt file2.txt >> tmp1 && mv tmp1 info.txt
				 	cat info.txt | uniq > tmp1 && mv tmp1 info.txt
				 	cat info.txt | awk -F'|' '{print $1" | ",$2" | ",$3" | ",$4" | ",$5" | ",$6}' > tmp1 && mv tmp1 info.txt
				 	rm file1.txt
				 	rm file2.txt
				 	rm list22
				 	rm file.txt 2> /dev/null 
				 	rm tmp2 2> /dev/null
				done
			N=$(cat list | wc -l)
			if [[ "${N}" == "${M}" ]];
				then
			      	      
					Z=$(echo ${k} | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
					echo "There is no accession number in the text of" "${Z}"
					echo ""
			
			fi
			cat list | sort | uniq > tmp && mv tmp list
		done
		     
		if [[ -z $(cat list) ]];
			then
				echo "There is no accession number in the text of" "${PMCID}"
				echo ""
				exit 0
		fi
		
## generating metadata
mapfile lines < list
if [[ -v meta ]]; 
	then
		if [[ $meta == '1' ]];
			then
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp1

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp2

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
				rm -rf "${out}"/"${B}"/"${B}"_tmp3

				paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

				rm -rf "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp33

				cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
				sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

				rm -rf "${out}"/"${B}"/"${B}"_tmp44
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
			done
			exit 0
			
		elif [[ $meta == '0' ]];
			then
				for idx in "${!lines[@]}";do

					B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
					X=$(echo "${B}" | rev | cut -c4- | rev)
					y=$(echo "${X}""nnn")
					l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
					mkdir "${out}"/"${B}" 
					wget -q -P "${out}"/"${B}" ""${l}""
					gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp1

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp2

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
					rm -rf "${out}"/"${B}"/"${B}"_tmp3

					paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

					rm -rf "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp33

					cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
					sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

					rm -rf "${out}"/"${B}"/"${B}"_tmp44
					rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
					done
	fi
fi	
	
	echo "summary report:"
	echo ""
	mapfile lines < list
	
	for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				D=$(cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Series_overall_design' | sed 's/!Series_overall_design//g' | sed 's/^[ \t]*//' | sed 's/"//g')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				esearch -db gds -query "${B}" | efetch | grep '^1\.\|^2\.\|Platform:' | grep -v "Series:" | sed 's/2\. /Type: /' | sed 's/1\. /Description: /' > tmp
				echo "${C}".  "${B}"> tmp1
				sed -i 's/^[ \t]*//' tmp1
				echo "Overall experiment desgin"":" "${D}" > tmp2
				cat tmp | grep "Description: " > tmp3
				cat tmp | grep "Type: " > tmp4
				cat tmp | grep -Eo '[0-9]{1,10} Samples' | sed 's/^[ \t]*//' > tmp5
				echo "##############################################" > tmp6
				cat tmp1 tmp2 tmp3 tmp4 tmp5 tmp6
				rm tmp1
				rm tmp2
				rm tmp3
				rm tmp4
				rm tmp5
				rm tmp6
				rm tmp
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt

	done
	

	echo ""
	echo "##############################################" 
	echo "$list" "specified to download"
	echo "##############################################" 
	echo ""
	
	
	
elif [[ $file == '2' ]];
	then
	cp ACCESSIONS.txt list1
        
    
	## converting ERP to GSE
	grep ERP list1 >> ERP
	grep -v ERP list1 > tmp_file
	mv tmp_file list1

	for j in $(cat ERP);
	do
	
	      (esearch -db gds -query ERP001942 | efetch --format runinfo | grep 'Accession:' | grep -Eo "GSE[0-9]{1,20}" | sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq ) >> list1
	      cat list1 | sort | uniq > tmp && mv tmp list1
	      
	done
    
	## converting PRJN to GSE   
	grep PRJN list1 >> PRJN
	grep -v PRJN list1 > tmp_file
	mv tmp_file list1

	for j in $(cat PRJN);
	do
	
	      (esearch -db sra -query ${j} | efetch --format runinfo | awk -F',' '{print $21}' | uniq | sed '1d') >> list1	
	      cat list1 | sort | uniq > tmp && mv tmp list1
	      
	done
	## converting SRP to GSE 
	grep SRP list1 >> SRP
	grep -v SRP list1 > tmp_file
	mv tmp_file list1

	for j in $(cat SRP);
	do
	
		A=$(esearch -db sra -query ${j} | efetch --format runinfo | awk -F',' '{print $21}' | uniq | sed '1d')
		pysradb srp-to-gse "${A}" | awk '{print $2}' | sed '1d' >> list1
		cat list1 | sort | uniq > tmp && mv tmp list1

	done
	## converting PRJNA to GSE 
	grep PRJNA list1 >> PRJNA
	grep -v PRJNA list1 > tmp_file
	mv tmp_file list1

	for j in $(cat PRJNA);
	do
	
		(esearch -db sra -query ${j} | efetch --format runinfo | awk -F',' '{print $21}' | uniq | sed '1d') >> list1	
		pysradb srp-to-gse "${A}" | awk '{print $2}' | sed '1d'
		cat list1 | sort | uniq > tmp && mv tmp list1
	
	done
	rm ERP
	rm SRP
	rm PRJN
	rm PRJNA
	
      
	for j in $(cat list1);
	do
	
		l="https://www.ncbi.nlm.nih.gov/pmc/articles/${j}/"
		echo $l >> PMCIDlist
		cat PMCIDlist | sort | uniq > tmp && mv tmp PMCIDlist
	
	done
	
	if [[ -v supp ]];
		  then
			  if [[ $supp == '1' ]];
			 	 then
			       
			
			   	 for p in $(cat PMCIDlist);do
				       
					lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
					lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
					Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
					mkdir "${out}"/"${Z}"
						for s in $(cat supp1); do
					
							#echo $s
							dir=$(echo ~)
							#cd $out
							axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
						done
				done
				exit 0
			  fi
	else
						for p in $(cat PMCIDlist);do
											 
							lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
							lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
							Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
							mkdir "${out}"/"${Z}"
						for s in $(cat supp1); do

							dir=$(echo ~)
							axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
						done
						done
		
	fi
	
	
	Types=("GSE" "PRJNA" "ERP" "SRP")

		touch info.txt
		for k in $(cat PMCIDlist);do
		
			printf '%s\n' ${k} > file.txt
				lynx -dump ${k} | grep -Eo "PMID: \[.*\][0-9]{1,20}" | sed -e 's/.*]//g' > PMID
			   	PMID=$(cat PMID)
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^TI/,/^PG/{{ /^PG/! p } }' | sed "s|TI  - |      |g" | sed 's/^[ \t]*//' | tr '\n' ' ' > t2
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AB/,/^FAU /{{ /^FAU /! p } }' | sed "s|AB  - |      |g" | sed 's/^[ \t]*//' | grep -v "CI  - " | tr '\n' ' ' > t3
				
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AU/,/^AD/{{ /^AD/! p } }' | sed "s|AU  - |      |g" | sed 's/^[ \t]*//' | grep -v "AUID- " | tr '\n' ';' > t4
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^PMID/,/^OWN/{{ /^OWN/! p } }' | sed "s|PMID- |PMID:|g" | sed 's/^[ \t]*//' > t5
				
				paste -d"|" t2 t3 t4 t5 > tmp2
				rm t2
				rm t3
				rm t4
				rm t5
			touch list
			M=$(cat list | wc -l)

				for i in "${Types[@]}"; do
					
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq >> list
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq > list22
				 	awk '
						{ 
						    for (i=1; i<=NF; i++)  {
						        a[NR,i] = $i
						    }
						}
						NF>p { p = NF }
						END {    
    						for(j=1; j<=p; j++) {
						        str=a[1,j]
						        for(i=2; i<=NR; i++){
						            str=str" "a[i,j];
						        }
						        print str
						    }
						}' list22 > file1.txt
					tr ' ' ';' < file1.txt > tmp1
					mv tmp1 file1.txt
					paste -d"|" file.txt file1.txt tmp2 > file2.txt 2> /dev/null
				 	cat info.txt file2.txt >> tmp1 && mv tmp1 info.txt
				 	cat info.txt | uniq > tmp1 && mv tmp1 info.txt
				 	cat info.txt | awk -F'|' '{print $1" | ",$2" | ",$3" | ",$4" | ",$5" | ",$6}' > tmp1 && mv tmp1 info.txt
				 	rm file1.txt
				 	rm file2.txt
				 	rm list22
				 	rm file.txt 2> /dev/null
				 	rm tmp2 2> /dev/null
				done
	      N=$(cat list | wc -l)
	      if [[ "${N}" == "${M}" ]];
	      then
	      	      
	      Z=$(echo ${k} | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
	      echo "There is no accession number in the text of" "${Z}"
	      echo ""
	      
	      fi
	     	      cat list | sort | uniq > tmp && mv tmp list
     done
     
     if [[ -z $(cat list) ]];
        then
     	     echo "There is no accession number in the text of" "${PMCID}"
	     echo ""
	     exit 0
        fi
	echo "summary report:"
	echo ""

	cp list list1
	mapfile lines < list
	
	## generating metadata
mapfile lines < list
if [[ -v meta ]]; 
	then
		if [[ $meta == '1' ]];
			then
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp1

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp2

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
				rm -rf "${out}"/"${B}"/"${B}"_tmp3

				paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

				rm -rf "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp33

				cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
				sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

				rm -rf "${out}"/"${B}"/"${B}"_tmp44
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
			done
			exit 0
			
		elif [[ $meta == '0' ]];
			then
				for idx in "${!lines[@]}";do

					B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
					X=$(echo "${B}" | rev | cut -c4- | rev)
					y=$(echo "${X}""nnn")
					l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
					mkdir "${out}"/"${B}" 
					wget -q -P "${out}"/"${B}" ""${l}""
					gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp1

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp2

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
					rm -rf "${out}"/"${B}"/"${B}"_tmp3

					paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

					rm -rf "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp33

					cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
					sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

					rm -rf "${out}"/"${B}"/"${B}"_tmp44
					rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
					done
	fi
fi		
	echo "summary report:"
	echo ""
	mapfile lines < list
	for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				D=$(cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Series_overall_design' | sed 's/!Series_overall_design//g' | sed 's/^[ \t]*//' | sed 's/"//g')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				esearch -db gds -query "${B}" | efetch | grep '^1\.\|^2\.\|Platform:' | grep -v "Series:" | sed 's/2\. /Type: /' | sed 's/1\. /Description: /' > tmp
				echo "${C}".  "${B}"> tmp1
				sed -i 's/^[ \t]*//' tmp1
				echo "Overall experiment desgin"":" "${D}" > tmp2
				cat tmp | grep "Description: " > tmp3
				cat tmp | grep "Type: " > tmp4
				cat tmp | grep -Eo '[0-9]{1,10} Samples' | sed 's/^[ \t]*//' > tmp5
				echo "##############################################" > tmp6
				cat tmp1 tmp2 tmp3 tmp4 tmp5 tmp6
				rm tmp1
				rm tmp2
				rm tmp3
				rm tmp4
				rm tmp5
				rm tmp6
				rm tmp
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt

	done
	
	
	echo ""
	echo "##############################################" 
	echo "${ACCESSIONS}" "specified to download"
	echo "##############################################" 
	echo ""
	
		
elif [[ $file == '3' ]];
	then
	    cp URLS.txt PMCIDlist
	    cp URLS.txt list1
	    
		if [[ -v supp ]];
		then
			if [[ $supp == '1' ]];
				then
					for p in $(cat PMCIDlist);do

						lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
						lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
						Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
						mkdir "${out}"/"${Z}"
						
					for s in $(cat supp1); do
							
						dir=$(echo ~)
						axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
					done
					done
					exit 0
			fi
		else
			for p in $(cat PMCIDlist);do
				 
				lynx -dump -listonly ${p} | grep '[.]xls\|[.]xlsx\|[.]txt\|[.]tsv' | grep -v "Article" | awk '{print $2}' | sort | uniq >> supp1
				lynx -dump -listonly ${p} | grep '[.]zip' | awk '{print $2}' | sort | uniq >> supp1
				Z=$(echo $p | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
				mkdir "${out}"/"${Z}"
			for s in $(cat supp1); do

				dir=$(echo ~)
				axel -n 4 -s1000000000000 $s -o "${out}"/"${Z}"
			done
			done
			
		fi
	Types=("GSE" "PRJNA" "ERP" "SRP")
	
		touch info.txt
		for k in $(cat URLS);do
		
			printf '%s\n' ${k} > file.txt
				lynx -dump ${k} | grep -Eo "PMID: \[.*\][0-9]{1,20}" | sed -e 's/.*]//g' > PMID
			   	PMID=$(cat PMID)
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^TI/,/^PG/{{ /^PG/! p } }' | sed "s|TI  - |      |g" | sed 's/^[ \t]*//' | tr '\n' ' ' > t2
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AB/,/^FAU /{{ /^FAU /! p } }' | sed "s|AB  - |      |g" | sed 's/^[ \t]*//' | grep -v "CI  - " | tr '\n' ' ' > t3
				
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^AU/,/^AD/{{ /^AD/! p } }' | sed "s|AU  - |      |g" | sed 's/^[ \t]*//' | grep -v "AUID- " | tr '\n' ';' > t4
				efetch -db pubmed -id ${PMID} -format medline | sed -n '/^PMID/,/^OWN/{{ /^OWN/! p } }' | sed "s|PMID- |PMID:|g" | sed 's/^[ \t]*//' > t5
				
				paste -d"|" t2 t3 t4 t5 > tmp2
				rm t2
				rm t3
				rm t4
				rm t5
			touch list
			M=$(cat list | wc -l)

				for i in "${Types[@]}"; do
					
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq >> list
					lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq > list22
				 	awk '
						{ 
						    for (i=1; i<=NF; i++)  {
						        a[NR,i] = $i
						    }
						}
						NF>p { p = NF }
						END {    
    						for(j=1; j<=p; j++) {
						        str=a[1,j]
						        for(i=2; i<=NR; i++){
						            str=str" "a[i,j];
						        }
						        print str
						    }
						}' list22 > file1.txt
					tr ' ' ';' < file1.txt > tmp1
					mv tmp1 file1.txt
					paste -d"|" file.txt file1.txt tmp2 > file2.txt 2> /dev/null
				 	cat info.txt file2.txt >> tmp1 && mv tmp1 info.txt
				 	cat info.txt | uniq > tmp1 && mv tmp1 info.txt
				 	cat info.txt | awk -F'|' '{print $1" | ",$2" | ",$3" | ",$4" | ",$5" | ",$6}' > tmp1 && mv tmp1 info.txt
				 	rm file1.txt
				 	rm file2.txt
				 	rm list22
				 	rm file.txt 2> /dev/null 
				 	rm tmp2 2> /dev/null
				done
	
	
	
	
	#for k in $(cat URLS);do
	#	touch list
	#	M=$(cat list | wc -l)
	#	for i in "${Types[@]}"; do
		
	#		lynx -dump ${k} | grep -Eo "$i[0-9]{1,20}"| sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq >> list
			
	#	done
		N=$(cat list | wc -l)
		if [[ "${N}" == "${M}" ]];
			then
				Z=$(echo ${k} | grep -Eo "PMC[0-9]{1,20}" | sed 's/ *$//' | sort | uniq)
				echo "There is no accession number in the text of" "${Z}"
				echo ""
		fi
		cat list | sort | uniq > tmp && mv tmp list
	done
  
  ## generating metadata
mapfile lines < list
if [[ -v meta ]]; 
	then
		if [[ $meta == '1' ]];
			then
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp1

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp2

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
				rm -rf "${out}"/"${B}"/"${B}"_tmp3

				paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

				rm -rf "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp33

				cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
				sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

				rm -rf "${out}"/"${B}"/"${B}"_tmp44
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
			done
			exit 0
			
		elif [[ $meta == '0' ]];
			then
				for idx in "${!lines[@]}";do

					B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
					X=$(echo "${B}" | rev | cut -c4- | rev)
					y=$(echo "${X}""nnn")
					l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
					mkdir "${out}"/"${B}" 
					wget -q -P "${out}"/"${B}" ""${l}""
					gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp1

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp2

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
					rm -rf "${out}"/"${B}"/"${B}"_tmp3

					paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

					rm -rf "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp33

					cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
					sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

					rm -rf "${out}"/"${B}"/"${B}"_tmp44
					rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
					done
	fi
fi	
	
	echo "summary report:"
	echo ""
	mapfile lines < list
	
	
	for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				D=$(cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Series_overall_design' | sed 's/!Series_overall_design//g' | sed 's/^[ \t]*//' | sed 's/"//g')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				esearch -db gds -query "${B}" | efetch | grep '^1\.\|^2\.\|Platform:' | grep -v "Series:" | sed 's/2\. /Type: /' | sed 's/1\. /Description: /' > tmp
				echo "${C}".  "${B}"> tmp1
				sed -i 's/^[ \t]*//' tmp1
				echo "Overall experiment desgin"":" "${D}" > tmp2
				cat tmp | grep "Description: " > tmp3
				cat tmp | grep "Type: " > tmp4
				cat tmp | grep -Eo '[0-9]{1,10} Samples' | sed 's/^[ \t]*//' > tmp5
				echo "##############################################" > tmp6
				cat tmp1 tmp2 tmp3 tmp4 tmp5 tmp6
				rm tmp1
				rm tmp2
				rm tmp3
				rm tmp4
				rm tmp5
				rm tmp6
				rm tmp
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt

	done
	
	
	echo "##############################################" 
	echo ""
	echo "##############################################" 
	echo "$Links specified to download"
	echo "##############################################" 
	echo ""
   fi
else
  echo ""
fi 


## downloading sequnce data using a list of accession numbers
if [[ -v ID ]];
	then
    
	for j in "${!ID[@]}"; do
	
		echo ${ID[j]} >> PMCIDlist
		
	done
		cat PMCIDlist | sort | uniq > tmp && mv tmp PMCIDlist
		cp PMCIDlist list1
		cat list1 | sort | uniq > tmp && mv tmp list1
	    
		#convert ERP to GSE 
		grep ERP list1 >> ERP
		grep -v ERP list1 > tmp_file
		mv tmp_file list1

		for j in $(cat ERP);do
		
		      (esearch -db gds -query ${j} | efetch --format runinfo | grep 'Accession:' | grep -Eo "GSE[0-9]{1,20}" | sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq ) >> list1
		      cat list1 | sort | uniq > tmp && mv tmp list1
		      
		done
	    
		#convert PRJN to GSE    
		grep PRJN list1 >> PRJN
		grep -v PRJN list1 > tmp_file
		mv tmp_file list1

		for j in $(cat PRJN);do
		
		      (esearch -db sra -query ${j} | efetch --format runinfo | awk -F',' '{print $21}' | uniq | sed '1d') >> list1	
		      cat list1 | sort | uniq > tmp && mv tmp list1
		      
		done
		#convert SRP to GSE 
		 grep SRP list1 >> SRP
		 grep -v SRP list1 > tmp_file
		 mv tmp_file list1

		for j in $(cat SRP);do

			(esearch -db gds -query ${j} | efetch --format runinfo | grep 'Accession:' | grep -Eo "GSE[0-9]{1,20}" | sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq ) >> list1
			cat list1 | sort | uniq > tmp && mv tmp list1

		done
		#convert PRJNA to GSE 
		grep PRJNA list1 >> PRJNA
		grep -v PRJNA list1 > tmp_file
		mv tmp_file list1

		for j in $(cat PRJNA);do
		
			(esearch -db gds -query "${j}" | efetch --format runinfo | grep 'Accession:' | grep -Eo "GSE[0-9]{1,20}" | sed 's/^[ \t]*//' | sed 's/ *$//' | sort | uniq ) >> list1
			cat list1 | sort | uniq > tmp && mv tmp list1

		done

		rm ERP
		rm SRP
		rm PRJN
		rm PRJNA
		cp list1 list

## generating metadata
mapfile lines < list
if [[ -v meta ]]; 
	then
		if [[ $meta == '1' ]];
			then
			for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
				cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp1

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp2

				awk '
				{ 
				    for (i=1; i<=NF; i++)  {
					a[NR,i] = $i
				    }
				}
				NF>p { p = NF }
				END {    
				    for(j=1; j<=p; j++) {
					str=a[1,j]
					for(i=2; i<=NR; i++){
					    str=str" "a[i,j];
					}
					print str
				    }
				}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
				rm -rf "${out}"/"${B}"/"${B}"_tmp3

				paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

				rm -rf "${out}"/"${B}"/"${B}"_tmp11
				rm -rf "${out}"/"${B}"/"${B}"_tmp22
				rm -rf "${out}"/"${B}"/"${B}"_tmp33

				cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
				sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

				rm -rf "${out}"/"${B}"/"${B}"_tmp44
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
			done
			exit 0
			
		elif [[ $meta == '0' ]];
			then
				for idx in "${!lines[@]}";do

					B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
					X=$(echo "${B}" | rev | cut -c4- | rev)
					y=$(echo "${X}""nnn")
					l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
					mkdir "${out}"/"${B}" 
					wget -q -P "${out}"/"${B}" ""${l}""
					gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_title' | sed 's/!Sample_title//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp1
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_geo_accession' | sed 's/!Sample_geo_accession//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp2
					cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Sample_source_name_ch1' | sed 's/!Sample_source_name_ch1//g' | sed 's/^[ \t]*//' | sed 's/ /_/g' > "${out}"/"${B}"/"${B}"_tmp3

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp1 > "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp1

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp2 > "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp2

					awk '
					{ 
					    for (i=1; i<=NF; i++)  {
						a[NR,i] = $i
					    }
					}
					NF>p { p = NF }
					END {    
					    for(j=1; j<=p; j++) {
						str=a[1,j]
						for(i=2; i<=NR; i++){
						    str=str" "a[i,j];
						}
						print str
					    }
					}' "${out}"/"${B}"/"${B}"_tmp3 > "${out}"/"${B}"/"${B}"_tmp33
					rm -rf "${out}"/"${B}"/"${B}"_tmp3

					paste "${out}"/"${B}"/"${B}"_tmp11 "${out}"/"${B}"/"${B}"_tmp22 "${out}"/"${B}"/"${B}"_tmp33 > "${out}"/"${B}"/"${B}"_tmp44

					rm -rf "${out}"/"${B}"/"${B}"_tmp11
					rm -rf "${out}"/"${B}"/"${B}"_tmp22
					rm -rf "${out}"/"${B}"/"${B}"_tmp33

					cat "${out}"/"${B}"/"${B}"_tmp44 | sed 's/"//g' > "${out}"/"${B}"/"${B}"_metadata  
					sed -i '1s/^/Sample_name\tRunID\tSampleID\n/' "${out}"/"${B}"/"${B}"_metadata

					rm -rf "${out}"/"${B}"/"${B}"_tmp44
					rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt
					done
	fi
fi	

## generating summary report	
	echo "summary report:"
	echo ""
	mapfile lines < list1
	
	for idx in "${!lines[@]}";do

				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				X=$(echo "${B}" | rev | cut -c4- | rev)
				y=$(echo "${X}""nnn")
				l="https://ftp.ncbi.nlm.nih.gov/geo/series/"${y}"/"${B}"/matrix/"${B}"_series_matrix.txt.gz"
				mkdir "${out}"/"${B}" 
				wget -q -P "${out}"/"${B}" ""${l}""
				gunzip "${out}"/"${B}"/"${B}"_series_matrix.txt.gz
				D=$(cat "${out}"/"${B}"/"${B}"_series_matrix.txt | grep '^!Series_overall_design' | sed 's/!Series_overall_design//g' | sed 's/^[ \t]*//' | sed 's/"//g')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				esearch -db gds -query "${B}" | efetch | grep '^1\.\|^2\.\|Platform:' | grep -v "Series:" | sed 's/2\. /Type: /' | sed 's/1\. /Description: /' > tmp
				echo "${C}".  "${B}"> tmp1
				sed -i 's/^[ \t]*//' tmp1
				echo "Overall experiment desgin"":" "${D}" > tmp2
				cat tmp | grep "Description: " > tmp3
				cat tmp | grep "Type: " > tmp4
				cat tmp | grep -Eo '[0-9]{1,10} Samples' | sed 's/^[ \t]*//' > tmp5
				echo "##############################################" > tmp6
				cat tmp1 tmp2 tmp3 tmp4 tmp5 tmp6
				rm tmp1
				rm tmp2
				rm tmp3
				rm tmp4
				rm tmp5
				rm tmp6
				rm tmp
				rm -rf "${out}"/"${B}"/"${B}"_series_matrix.txt

	done
	
	
	echo "##############################################" 
	echo ""
	echo "##############################################" 
	echo "${ID[@]}" "specified to download"
	echo "##############################################" 
	echo ""
fi

## selecting specefic accession number(s) to download 
if [[ -v down ]];
	then
		if [[ $down == '1' ]];
		then
			echo "Enter the number of accession codes that you want to downoad: "  
			read n
			i=1 
			while [[ $i -le $n ]]
			do
				echo "Enter the number of accession: "  
				read number 
				echo $number >> list2
				i=$(($i+1))
			done
	
		mapfile lines < list1	
		for p in $(cat list2);do
			for idx in "${!lines[@]}";do
			
				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				if [[ $p == $C ]];then
				
				echo $B >> list1
				
				fi
		
				echo "##############################################" 
				echo ""
				echo "##############################################" 
				echo "$list1" "selected to download"
				echo "##############################################" 
				echo ""
				done
				done
		fi
fi

## Generating the list of downloads 
grep PRJN list1 >> PRJN
grep -v PRJN list1 > tmp_file
mv tmp_file list1
	for j in $(cat PRJN);do
	
		(esearch -db sra -query ${j} | efetch --format runinfo | awk -F',' '{print $21}' | uniq | sed '1d') >> list1	
		cat list1 | sort | uniq > tmp && mv tmp list1
		
	done
	#convert SRP to GSE 
	grep SRP list1 >> SRP
	grep -v SRP list1 > tmp_file
	mv tmp_file list1

	for j in $(cat SRP);do

		A=$(esearch -db sra -query ${j} | efetch --format runinfo | awk -F',' '{print $21}' | uniq | sed '1d')
		pysradb srp-to-gse "${A}" | awk '{print $2}' | sed '1d' >> list1
		cat list1 | sort | uniq > tmp && mv tmp list1
		
	done
	#convert PRJNA to GSE 
	grep PRJNA list1 >> PRJNA
	grep -v PRJNA list1 > tmp_file
	mv tmp_file list1
	for j in $(cat PRJNA);do
		A=$(esearch -db sra -query ${j} | efetch --format runinfo | awk -F',' '{print $21}' | uniq | sed '1d')
		pysradb srp-to-gse "${A}" | awk '{print $2}' | sed '1d' >> list1
		cat list1 | sort | uniq > tmp && mv tmp list1
	done
	rm SRP
	rm PRJN
	rm PRJNA
	
	echo "feching specified dataset(s) from the database: "
	echo ""
	echo -ne '>>>                       [10%]\r'
	sleep 2
	for j in $(cat list);do
		
		ffq --ftp $j > "${out}"/$j/check$j.txt 2>&1
		cat "${out}"/$j/check$j.txt | grep -B3 -A7 'filetype": null,' | grep -Eo '"url": "[^"]*"' | sed 's/"url": //g' | sed 's/"//g' > "${out}"/$j/proccessed_url$j.txt
		cat "${out}"/$j/check$j.txt | grep -n -B6 -A4 '"md5": null,' | sed -n 's/^\([0-9]\{1,\}\).*/\1d/p' | grep -v 'md5": null,' | sed -f - "${out}"/$j/check$j.txt > "${out}"/$j/temp.txt && mv "${out}"/$j/temp.txt "${out}"/$j/check$j.txt
		
	done
	sleep 2
	echo -ne '>>>>>>>                   [40%]\r'
	for j in $(cat list);do
		rec="$(cat "${out}"/$j/check$j.txt | grep '"accession":\|"filename":\|"filetype":\|"filesize":\|"filenumber":\|"md5":\|"urltype":\|"url":' | awk '{print $1}' | sort | uniq | wc -l | bc -l)"
		if (( $(echo "${rec} == 8" | bc -l) ));
			then
				echo 
		else
			echo 
			echo error for "$j"
			echo No sample found for "$j". Either the provided "$j" is invalid or raw data was not provided for this record
			cat list | grep -v "$j" | sort | uniq > tmp && mv tmp list
			cp list list1
			rm -rf "${out}"/$j/check$j.txt 2> /dev/null
			rm -rf "${out}"/$j/proccessed_url$j.txt 2> /dev/null
			rm -rf "${out}"/$j 2> /dev/null
		fi
		
	done
	sleep 2
	echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>[100%]\r'
	echo -ne '\n'

	## search and download processed data
	if [[ -v processed ]];
		then
			for i in $(cat list1);do
					
				for s in $(cat $i/proccessed_url$i.txt); do
				
					axel -n 4 -s1000000000000 $s -o "${out}"/"${i}"
				
				done
			done
			
	fi


	## check the total disk space 
	echo ""
	echo "local disk memory size checking: "
	echo ""

	for j in $(cat list);do
	
		Dirsize=$(df -Ph "$out" | tail -1 | awk '{print $4}' | sed 's/G//g')
		URLsize=$(echo $(cat "${out}"/$j/check$j.txt | grep '"filesize": ' | sed 's/"filesize": //g' | sed 's/,*$//g' | sed 's/^[ \t]*//' | paste -sd+ | bc)/1024/1024/1024 | bc -l | sed -re 's/([0-9]+\.[0-9]{2})[0-9]+/\1/g')

			if (( $(echo "${Dirsize} > ${URLsize}" | bc -l ) ));
				then
					echo 
					echo ------------------------------------------------------------------
					echo there is "${Dirsize}" GB space avialable in "${out}" 
					echo "$j" size is "${URLsize}" GB
					echo There is adequate space in "${out}" to download all specified files. 
					echo ------------------------------------------------------------------
					echo 
				else
					echo 
					echo ---------------------------------------------------------------------------------------------------
					echo there is "${Dirsize}" GB space avialable in "${out}" 
					echo "total size of sequence data for below accession number(s)"
					echo "$(cat list)"
					echo is "${URLsize}" GB
					echo  "${out}" does not have enough space for all files you aim to download. Please change the directroy.
					echo ---------------------------------------------------------------------------------------------------
					echo
					rm list
					rm list1
					rm PMCIDlist
					exit 0 
			fi
	      
	done

	## specifying types of sequence data and generating Aspera download URL
	cat list1 | wc -l > lines
	if [[ -v type ]];
		then
			echo "you select the type $type"
			if [[ $type == 'bam' ]];
				then
					
					for j in $(cat list1);do
					
					cat "${out}"/$j/check$j.txt | grep -B 3 -A 5 'filetype": "bam' | grep -Eo '"url": "[^"]*"' | sed 's/"url": //g' | sed 's/"//g' | sed 's#ftp://ftp.sra.ebi.ac.uk/#era-fasp@fasp.sra.ebi.ac.uk:#g' > "${out}"/$j/urls$j.txt
					
					done
			elif [[ $type == 'fastq' ]] ;
				then
					echo "you select the type $type"
					for j in $(cat list1);do
					
						cat "${out}"/$j/check$j.txt | grep -B 3 -A 5 'filetype": "fastq' | grep -Eo '"url": "[^"]*"' | sed 's/"url": //g' | sed 's/"//g' | sed 's#ftp://ftp.sra.ebi.ac.uk/#era-fasp@fasp.sra.ebi.ac.uk:#g' > "${out}"/$j/urls$j.txt
						
					done
			elif [[ $type == 'fasta' ]] ;
				then
					echo "you select the type $type"
					for j in $(cat list1);do
					
					cat "${out}"/$j/check$j.txt | grep -B 3 -A 5 'filetype": "fasta' | grep -Eo '"url": "[^"]*"' | sed 's/"url": //g' | sed 's/"//g' | sed 's#ftp://ftp.sra.ebi.ac.uk/#era-fasp@fasp.sra.ebi.ac.uk:#g' > "${out}"/$j/urls$j.txt
					
					done
			elif [[ $type == 'vcf' ]] ;
				then
					echo "you select the type $type"
					for j in $(cat list1);do
					
					       cat "${out}"/$j/check$j.txt | grep -B 3 -A 5 'filetype": "vcf' | grep -Eo '"url": "[^"]*"' | sed 's/"url": //g' | sed 's/"//g' | sed 's#ftp://ftp.sra.ebi.ac.uk/#era-fasp@fasp.sra.ebi.ac.uk:#g' > "${out}"/$j/urls$j.txt
					       
					done
			fi
				       
	else
					echo "KARAJ is downloading files corresponding to the selected accession number(s)"
					for j in $(cat list1);do
				    
				    		 cat "${out}"/$j/check$j.txt | grep -v -A4 -B6 '"md5": null,' | grep -v '"md5": null,' | grep -Eo '"url": "[^"]*"' | sed 's/"url": //g' | sed 's/"//g' | sed 's#ftp://ftp.sra.ebi.ac.uk/#era-fasp@fasp.sra.ebi.ac.uk:#g' > "${out}"/$j/urls$j.txt
				    		 
					done
	fi

## download sequence data using Aspera in a parallel mode
if [[ -v core ]];
	then
		k=$core
		echo "${k}" "cores are using"
		SECONDS=0
		start=$SECONDS
		
			for w in $(cat list1);do
			
				echo "KARAJ is downloading" "${w}" 
				cat "${out}"/$w/urls$w.txt | parallel -j "${k}" ~/.aspera/connect/bin/ascp -QT -l 300m --retry-timeout=1800 \
				-P33001 -i $HOME/.aspera/connect/etc/asperaweb_id_dsa.openssh -q {} "${out}"/$w
				echo "downloading" "${w}" "is completed"
				duration=$(( SECONDS - start ))
				echo "This run took $duration seconds"
				rm "${out}"/$w/urls$w.txt  2> /dev/null
				rm "${out}"/$w/check$w.txt  2> /dev/null
				rm "${out}"/$w/proccessed_url$w.txt  2> /dev/null
			done
	  else	
		th=$(lscpu | egrep 'Model name|Socket|Thread|NUMA|CPU\(s\)' | grep "^CPU(s):" | sed 's/CPU(s)://g' | sed 's/^[ \t]*//'| bc ) 
		k=$(expr "${th}" - 1)
		echo "${k}" "cores are using"
		SECONDS=0
		start=$SECONDS
		
			for w in $(cat list1);do
			
				echo "KARAJ is downloading" "${w}" 
				cat "${out}"/$w/urls$w.txt | parallel -j "${k}" ~/.aspera/connect/bin/ascp -QT -l 300m --retry-timeout=1800 \
				-P33001 -i $HOME/.aspera/connect/etc/asperaweb_id_dsa.openssh -q {} "${out}"/$w
				echo "downloading" "${w}" "is completed"
				rm "${out}"/$w/urls$w.txt  2> /dev/null
				rm "${out}"/$w/check$w.txt  2> /dev/null
				rm "${out}"/$w/proccessed_url$w.txt  2> /dev/null
			done
		
		duration=$(( SECONDS - start ))
		echo "This run took $duration seconds"
fi
	
rm -rf list 2> /dev/null
rm -rf list1 2> /dev/null
rm -rf PMCIDlist 2> /dev/null
rm -rf supp1 2> /dev/null
rm -rf lines 2> /dev/null
rm -rf tmp 2> /dev/null

#######  END  #######


