#!/usr/bin/env bash

## this the installing function for KARAJ
## please run this sh file first to install all needed requirments to run KARAJ  

# check the required dependencies

echo 
echo --------------------------------------------------------------------------
echo Dependencies Checking proccess has been started  
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
    fi
done

for pkg in "${packages[@]}"; do

    is_pkg_installed=$(dpkg-query -s "$pkg" 2>/dev/null | grep "install ok installed") 
    if [[ "${is_pkg_installed}" == "Status: install ok installed" && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
        echo "$pkg"
        echo $(dpkg-query -s "$pkg" 2>/dev/null | grep "Version: ") 
        echo  "is already installed."
        echo --------------------------------------------------------------------------
        echo 
    elif   [[ "${is_pkg_installed}" != "Status: install ok installed" && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
    	echo  "$pkg" installing proccess has failed. It needs to be installed manually.
    	echo --------------------------------------------------------------------------
        echo 
      fi
done


## checking the satus of ffq package

pip_packages=(ffq)
for pkg in "${pip_packages[@]}"; do

    is_pkg_installed=$("$pkg" -h | grep -Eo '^usage: ffq')
    if [[ "${is_pkg_installed}" == 'usage: ffq' ]]; then
        echo 
        echo --------------------------------------------------------------------------
        echo "$pkg" 
        echo $("$pkg" -h | grep -Eo '^ffq .....' | sed 's/ffq/Version:/')
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
    fi
done

for pkg in "${pip_packages[@]}"; do

is_pkg_installed=$("$pkg" -h | grep -Eo '^usage: pysradb')
    if [[ "${is_pkg_installed}" != 'usage: ffq' && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
        echo "$pkg"
        echo $("$pkg" -h | grep -Eo '^ffq .....' | sed 's/ffq/Version:/')
        echo "is already installed."
        echo --------------------------------------------------------------------------
        echo 
    elif   [[ "${is_pkg_installed}" != 'usage: ffq' && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
    	echo  "$pkg" installing proccess has failed. It needs to be installed manually.
    	echo --------------------------------------------------------------------------
        echo 
      fi
done

## checking the satus of pysradb package

pip_packages=(pysradb)
for pkg in "${pip_packages[@]}"; do

    is_pkg_installed=$("$pkg" -h | grep -Eo '^usage: pysradb')
    if [[ "${is_pkg_installed}" == 'usage: pysradb' ]]; then
        echo 
        echo --------------------------------------------------------------------------
        echo "$pkg" 
        echo $("$pkg" -h | grep -Eo '^version: ......')
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
    fi
done

for pkg in "${pip_packages[@]}"; do

is_pkg_installed=$("$pkg" -h | grep -Eo '^usage: ffq')
    if [[ "${is_pkg_installed}" != 'usage: pysradb' && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
        echo "$pkg"
        echo $("$pkg" -h | grep -Eo '^version: ......')
        echo "is already installed."
        echo --------------------------------------------------------------------------
        echo 
    elif  [[ "${is_pkg_installed}" != 'usage: pysradb' && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
    	echo  "$pkg" installing proccess has failed. It needs to be installed manually.
    	echo --------------------------------------------------------------------------
        echo 
      fi
done

## checking the satus of aspera connect package

web_packages=(aspera)
ali=$(pwd)

for pkg in "${web_packages[@]}"; do

    is_pkg_installed=$(~/."$pkg"/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect version") 
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
    fi
done

for pkg in "${web_packages[@]}"; do

    is_pkg_installed=$(~/."$pkg"/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect version") 
    if [[ "${is_pkg_installed}" != "Aspera Connect version" && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
        echo $(~/.aspera/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect")
        echo $(~/.aspera/connect/bin/ascp --version | head -1 | sed 's/Aspera Connect version/Version:/')
	echo  "is already installed."
        echo --------------------------------------------------------------------------
        echo 
    elif   [[ "${is_pkg_installed}" != "Aspera Connect version" && "$TEMP" == "1" ]]; then
        echo 
        echo --------------------------------------------------------------------------
    	echo  "$pkg" can not be installed. You need to install it manually.
    	echo --------------------------------------------------------------------------
        echo 
      fi
done


# check if KARAJ has been installed successfully

pkg1=(aspera)
is_aspera_installed=$(~/."$pkg1"/connect/bin/ascp --version | head -1 | grep -Eo "Aspera Connect version") 
pkg2=(ffq)
is_ffq_installed=$("$pkg2" -h | grep -Eo '^usage: ffq')
pkg3=(lynx)
is_lynx_installed=$(dpkg-query -s "$pkg3" 2>/dev/null | grep "install ok installed") 
pkg4=(ncbi-entrez-direct)
is_ncbi_installed=$(dpkg-query -s "$pkg4" 2>/dev/null | grep "install ok installed") 

if [[ "${is_aspera_installed}" == "Aspera Connect version" && "${is_ffq_installed}" == 'usage: ffq' && "${is_ncbi_installed}" == "Status: install ok installed" && "${is_lynx_installed}" == "Status: install ok installed" ]]; then
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

## END

