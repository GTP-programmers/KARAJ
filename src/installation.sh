#!/usr/bin/env bash

## this the installing function for KARAJ
## please run this sh file first to install all needed requirments to run KARAJ  

# check the required dependencies

echo 
echo --------------------------------------------------------------------------
echo Checking required dependencies has been started  
echo --------------------------------------------------------------------------
echo 

## checking the satus of lynx and ncbi-entrez-direct pakages

packages=(lynx ncbi-entrez-direct axel wget)
for pkg in "${packages[@]}"; do

    is_pkg_installed=$(dpkg-query -s "$pkg" 2>/dev/null | grep "install ok installed") 
	if [ "${is_pkg_installed}" == "Status: install ok installed" ]; then
		echo 
		echo --------------------------------------------------------------------------
		echo "$pkg"
		echo $(dpkg-query -s "$pkg" 2>/dev/null | grep "Version: ") 
		echo  "is already installed."
		echo --------------------------------------------------------------------------
		echo 
	else
		echo 
		echo --------------------------------------------------------------------------
		echo "$pkg" needs to be installed.
		echo --------------------------------------------------------------------------
		echo 
		echo --------------------------------------------------------------------------
		echo   "$pkg" is installing now.
		echo --------------------------------------------------------------------------
		echo 
		sudo apt-get update 
		sudo apt-get -y install "$pkg"
		TEMP=1
		is_pkg_installed=$(dpkg-query -s "$pkg" 2>/dev/null | grep "install ok installed") 
    		if [[ "${is_pkg_installed}" == "Status: install ok installed" && "$TEMP" == "1" ]]; then
			echo 
			echo --------------------------------------------------------------------------
			echo "$pkg"
			echo $(dpkg-query -s "$pkg" 2>/dev/null | grep "Version: ") 
			echo  "is already installed."
			echo --------------------------------------------------------------------------
			echo
		fi    
	fi
done

for pkg in "${packages[@]}"; do

	is_pkg_installed=$(dpkg-query -s "$pkg" 2>/dev/null | grep "install ok installed")  
	if   [[ "${is_pkg_installed}" != "Status: install ok installed" && "$TEMP" == "1" ]]; then
		echo 
		echo --------------------------------------------------------------------------
		echo  "$pkg" installation proccess has failed. It needs to be installed manually.
		echo --------------------------------------------------------------------------
		echo
	fi
done


## checking the satus of ffq package

pip_packages=(ffq)
for pkg in "${pip_packages[@]}"; do

	is_pkg_installed=$("$pkg" -h 2>/dev/null | grep -Eo '^usage: ffq')
	if [[ "${is_pkg_installed}" == 'usage: ffq' ]]; then
		echo 
		echo --------------------------------------------------------------------------
		echo "$pkg" 
		echo $("$pkg" -h 2>/dev/null | grep -Eo '^ffq .....' | sed 's/ffq/Version:/')
		echo  "is already installed."
		echo --------------------------------------------------------------------------
		echo 
	else
		echo --------------------------------------------------------------------------
		echo "$pkg" needs to be installed.
		echo --------------------------------------------------------------------------
		echo 
		echo --------------------------------------------------------------------------
		echo   "$pkg" is installing now.
		echo --------------------------------------------------------------------------
		echo 
		pip install --upgrade pip
		pip install "$pkg"
		TEMP=1
		is_pkg_installed=$("$pkg" -h 2>/dev/null | grep -Eo '^usage: ffq')
			if [[ "${is_pkg_installed}" == 'usage: ffq' && "$TEMP" == "1" ]]; then
				echo 
				echo --------------------------------------------------------------------------
				echo "$pkg"
				echo $("$pkg" -h 2>/dev/null | grep -Eo '^ffq .....' | sed 's/ffq/Version:/')
				echo "is already installed."
				echo --------------------------------------------------------------------------
				echo 
			fi
	fi
done

for pkg in "${pip_packages[@]}"; do

	if   [[ "${is_pkg_installed}" != 'usage: ffq' && "$TEMP" == "1" ]]; then
		echo 
		echo --------------------------------------------------------------------------
		echo  "$pkg" installation proccess has failed. It needs to be installed manually.
		echo --------------------------------------------------------------------------
		echo 
	fi
done

## checking the satus of pysradb package

pip_packages=(pysradb)
for pkg in "${pip_packages[@]}"; do

	is_pkg_installed=$("$pkg" -h 2>/dev/null | grep -Eo '^usage: pysradb')
	if [[ "${is_pkg_installed}" == 'usage: pysradb' ]]; then
		echo 
		echo --------------------------------------------------------------------------
		echo "$pkg" 
		echo $("$pkg" -h 2>/dev/null | grep -Eo '^version: ......')
		echo  "is already installed."
		echo --------------------------------------------------------------------------
		echo 
	else
		echo --------------------------------------------------------------------------
		echo "$pkg" needs to be installed.
		echo --------------------------------------------------------------------------
		echo 
		echo --------------------------------------------------------------------------
		echo   "$pkg" is installing now.
		echo --------------------------------------------------------------------------
		echo 
		pip install --upgrade pip
		pip install "$pkg"
		TEMP=1
		is_pkg_installed=$("$pkg" -h 2>/dev/null | grep -Eo 'usage: pysradb')
			if [[ "${is_pkg_installed}" == 'usage: pysradb' && "$TEMP" == "1" ]]; then
				echo 
				echo --------------------------------------------------------------------------
				echo "$pkg"
				echo $("$pkg" -h | grep -Eo '^version: ......')
				echo "is already installed."
				echo --------------------------------------------------------------------------
				echo
			fi 	
	fi
done

for pkg in "${pip_packages[@]}"; do

	if  [[ "${is_pkg_installed}" != 'usage: pysradb' && "$TEMP" == "1" ]]; then
		echo 
		echo --------------------------------------------------------------------------
		echo  "$pkg" installation proccess has failed. It needs to be installed manually.
		echo --------------------------------------------------------------------------
		echo 
	fi
done

## checking the satus of aspera connect package

web_packages=(aspera)
ali=$(pwd)

for pkg in "${web_packages[@]}"; do

	is_pkg_installed=$(~/."$pkg"/connect/bin/ascp --version 2>/dev/null | head -1 | grep -Eo "Aspera Connect version") 
	if [[ "${is_pkg_installed}" == "Aspera Connect version" ]]; then
		echo 
		echo --------------------------------------------------------------------------
		echo $(~/.aspera/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect")
		echo $(~/.aspera/connect/bin/ascp --version | head -1 | sed 's/Aspera Connect version/Version:/')
		echo  "is already installed."
		echo --------------------------------------------------------------------------
		echo 
	else
		echo 
		echo --------------------------------------------------------------------------
		echo "$pkg" needs to be installed.
		echo --------------------------------------------------------------------------
		echo 
		echo --------------------------------------------------------------------------
		echo   "$pkg" will be installed.
		echo --------------------------------------------------------------------------
		echo
		cd
		git clone https://github.com/aertslab/install_aspera_connect
		cd install_aspera_connect
		chmod +x install_aspera_connect.sh
		./install_aspera_connect.sh
		export PATH=$PATH:~/.aspera/connect/bin/
		echo 'export PATH=$PATH:~/.aspera/connect/bin/' >> ~/.bash_profile
		cd "$ali"
		TEMP=1
		is_pkg_installed=$(~/."$pkg"/connect/bin/ascp --version 2>/dev/null | head -1 | grep -Eo "Aspera Connect version") 
			if [[ "${is_pkg_installed}" == "Aspera Connect version" && "$TEMP" == "1" ]]; then
				echo 
				echo --------------------------------------------------------------------------
				echo $(~/.aspera/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect")
				echo $(~/.aspera/connect/bin/ascp --version | head -1 | sed 's/Aspera Connect version/Version:/')
				echo  "is already installed."
				echo --------------------------------------------------------------------------
				echo
			fi

	fi
done

for pkg in "${web_packages[@]}"; do

	if   [[ "${is_pkg_installed}" != "Aspera Connect version" && "$TEMP" == "1" ]]; then
		echo 
		echo --------------------------------------------------------------------------
		echo  "$pkg" installation proccess has failed. It needs to be installed manually.
		echo --------------------------------------------------------------------------
		echo 
	fi
done


# check if KARAJ has been installed successfully

pkg1=(aspera)
is_aspera_installed=$(~/."$pkg1"/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect version") 
pkg2=(ffq)
is_ffq_installed=$("$pkg2" -h 2>/dev/null | grep -Eo '^usage: ffq')
pkg3=(lynx)
is_lynx_installed=$(dpkg-query -s "$pkg3" 2>/dev/null | grep "install ok installed") 
pkg4=(ncbi-entrez-direct)
is_ncbi_installed=$(dpkg-query -s "$pkg4" 2>/dev/null | grep "install ok installed")
pkg5=(wget)
is_wget_installed=$(dpkg-query -s "$pkg5" 2>/dev/null | grep "install ok installed")
pkg6=(pysradb)
is_pkg_installed=$("$pkg6" -h 2>/dev/null | grep -Eo '^usage: pysradb')
pkg7=(axel)
is_axel_installed=$(dpkg-query -s "$pkg7" 2>/dev/null | grep "install ok installed") 


if [[ "${is_aspera_installed}" == "Aspera Connect version" && "${is_ffq_installed}" == 'usage: ffq' && "${is_ncbi_installed}" == "Status: install ok installed" && "${is_lynx_installed}" == "Status: install ok installed" && "${is_wget_installed}" == "Status: install ok installed" && "${is_pysradb_installed}" == "usage: pysradb" && "${is_axel_installed}" == "install ok installed" ]]; then
        echo 
        echo "##########################################################################"
        echo "KARAJ"
        echo "Version: v1.0"
	echo  "has been installed successfully."
        echo "##########################################################################"
        echo 
else
        echo 
        echo "##########################################################################"
    	echo  "Instalation has faield. Please install required packages manually."
    	echo "##########################################################################"
        echo 
fi

## END ##

