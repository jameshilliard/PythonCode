#!/bin/bash

# Author        :   
# Description   :
#   This tool is using 
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#30 MAR 2012    |   1.0.0   | Andy      | Inital Version

VER="1.0.0"
echo "$0 version : ${VER}"

USAGE()
{
    cat <<usge
USAGE : 
    
    bash $0 -p <product type> -f <firmware version> -tp <template product type> -tf <template firmware version> -i <post files directory> -d <data model> -o <report>

OPTIONS:
    -p) product type
            such as Q2KH , FT and so on ...

    -f) firmware version
            such as 34.20L.0j , FTH-BHRK2-10-10-08I and so on ...

    -tp) template product type
            it's a existing product
            such as Q2KH
            default is template_product

    -tf) template firmware version
            it's a existing firmware
            such 34.20L.0j
            defult is template_firmware

    -i) post files directory

    -d) data model file 
            such TV2KH_DeviceType_31.60.1.xml

    -o) report file

eg:
    bash $0 -p test_product -f test_firmware -tp template_product -tf template_firmware -i /root/Downloads/post_files -d /root/TV2KH_DeviceType_31.60.1.xml -o report.log

usge
}

platform_path=$SQAROOT/platform/$G_PFVERSION
bin_path=$SQAROOT/bin/$G_BINVERSION
tsuite_path=$SQAROOT/testsuites/$G_BINVERSION
tools_path=$SQAROOT/tools/$G_BINVERSION
split_1="==============================================="
split_2="-----------------------------------------------"

while [ -n "$1" ];
do
    case "$1" in
        -p)
            product=$2
            shift 2
            ;;

        -f)
            firmware=$2
            shift 2
            ;;

        -tp)
            template_product=$2
            shift 2
            ;;

        -tf)
            template_firmware=$2
            shift 2
            ;;

        -i)
            post_files=$2
            shift 2
            ;;

        -d)
            data_model=$2
            shift 2
            ;;

        -o)
            log=$2
            log_path=`pwd`
            report=$log_path/$log
            shift 2
            ;;

        -h)
            USAGE
            exit 1
            ;;

        -*)
            echo "'$1' not supported."
            echo -e $usage
            exit 1
            ;;
    esac
done

if [ -z "$product" ] ;then
    echo "Please input product type!"
    USAGE
    exit 1
fi

if [ -z "$firmware" ] ;then
    echo "Please input firmware version!"
    USAGE
    exit 1
fi

if [ -z "$template_product" ] ;then
    echo "Set template dir to template_product"
    template_product=template_product
else
    if [ ! -d "$platform_path/$template_product" ] ;then
        echo "No such template product : <$template_product>"
        exit 1
    fi
fi

if [ -z "$template_firmware" ] ;then
    echo "Set template dir to template_firmware"
    template_firmware=template_firmware
else
    if [ ! -d "$platform_path/$template_product/config/$template_firmware" ] ;then
        echo "NO such templat firmware : <$template_product -- $template_firmware>"
        exit 1
    fi
fi

if [ -z "$post_files" ] ;then
    echo "WARNING : NOT assign the post files directory!"
else
    if [ ! -d "$post_files" ] ;then
        echo "NO such post files directory : <$post_files>"
        exit 1
    fi
fi

if [ -z "$data_model" ] ;then
    echo "WARNING : NOT assign the data model files!"
else
    if [ ! -f "$data_model" ] ;then
        echo "NO such data model : <$data_model>"
        exit 1
    fi
fi

if [ "$report" ] ;then
    rm -f $report
    date | tee $report
else
    echo "WARNING : NOT assign the report file!"
fi

create_tcases(){
    echo "Create test cases directory ..." | tee -a $report

    if [ -d "$platform_path/$product/tcases" ] ;then
        echo "The directory : <$platform_path/$product/tcases> is already existing!" | tee -a $report
        echo "Skipped create tcases directory!" | tee -a $report
    else
        echo "cd $platform_path"
        cd $platform_path 

        echo "mkdir $product"
        mkdir $product

        echo "cp -r $platform_path/$template_product/tcases/ $platform_path/$product/"
        cp -r $platform_path/$template_product/tcases/ $platform_path/$product/

        echo "Create test cases directory is ready!" | tee -a $report
    fi
}

remove_old_files(){
    echo $split_2 | tee -a $report
    echo "Remove old files ..." | tee -a $report

    if [ "$product" != "$template_product" ] ;then
        echo "Remove all old post files (regular file) in the new config directory" | tee -a $report

        echo "find -type f | xargs -n 50 rm -f"
        find -type f | xargs -n 50 rm -f
    else
        echo "The import product <$product> is the same as template product <$template_product>" | tee -a $report
        echo "Keep the origin post files" | tee -a $report
    fi
}

rename_wifi_link(){
    echo $split_2 | tee -a $report
    echo "Rename wifi symbolic link ..." | tee -a $report

    echo "cd $platform_path/$product/config/$firmware/wireless"
    cd $platform_path/$product/config/$firmware/wireless

    find -type l -fprint wifi_link.tmp

    cat wifi_link.tmp | while read file
    do
        target=`readlink $file`
        target=${target/$template_product/$product}
    
        link_name=${file/$template_product/$product}
    
        rm -f $file
    
        ln -s "$target" "$link_name" 2> /dev/null 
    done
    
    rm -f  wifi_link.tmp
    
    echo "Rename wifi symbolic link is ready!" | tee -a $report 
}

import_data_model(){
    echo "Import data model file ..." | tee -a $report

    echo "cd $tools_path/common/"
    cd $tools_path/common/

    echo "python parse_data_model.py -c $data_model -o $platform_path/$product/config/$firmware/data_model"
    python parse_data_model.py -c $data_model -o $platform_path/$product/config/$firmware/data_model
    rc=$?

    echo "cp $data_model $tools_path/common/data_model/"
    cp $data_model $tools_path/common/data_model/

    return $rc
}

update_new_files(){
    echo $split_2 | tee -a $report
    echo "Update new files ..." | tee -a $report

    if [ "$post_files" ] ;then
        echo "Assign post files directory <$post_files>, update post file now" | tee -a $report

        echo "cp -rf $post_files/*  $platform_path/$product/config/$firmware"
        cp -rf $post_files/*  $platform_path/$product/config/$firmware
    else
        echo "NOT assign post files directory, skipping update post file" | tee -a $report
    fi

    rename_wifi_link

    echo $split_2 | tee -a $report
    echo "check lack post files ..." | tee -a $report
    cd $platform_path/$product/config/$firmware
    find -L -type l | tee -a $report

    echo $split_2 | tee -a $report
    if [ "$data_model" ] ;then
        echo "Assign data model file <$data_model>, update data model now" | tee -a $report

        import_data_model

        if [ $? -eq 0 ] ;then
            echo "Import data model file is ready!" | tee -a $report
        else
            echo "Parse data model file is Failed!" | tee -a $report
        fi
    else
        echo "NOT assign data model file" | tee -a $report
        if [ -f "$platform_path/$template_product/config/$template_firmware/data_model" ] ;then
            echo "Uptate data model from template product"  | tee -a $report

            echo "$platform_path/$template_product/config/$template_firmware/data_model $platform_path/$product/config/$firmware/data_model"
            cp $platform_path/$template_product/config/$template_firmware/data_model $platform_path/$product/config/$firmware/data_model
        else
            echo "skipping update data model" | tee -a $report
        fi
    fi
}

create_config(){
    echo "Create config directory ..." | tee -a $report

    if [ -d $platform_path/$product/config/$firmware ] ;then
        echo "The directory : <$platform_path/$product/config/$firmware> is already existing!" | tee -a $report
        #echo "Skipped create config directory!" | tee -a $report
    else
        echo "cd $platform_path"
        cd $platform_path

        echo "mkdir -vp $product/config/$firmware"
        mkdir -vp $product/config/$firmware
    fi

    echo "cd $platform_path/$product/config/$firmware"
    cd $platform_path/$product/config/$firmware

    echo "Create config dir-tree refer to template dir-tree <$platform_path/$template_product/config/$template_firmware>"
    echo "cp -r $platform_path/$template_product/config/$template_firmware/* ."
    cp -r $platform_path/$template_product/config/$template_firmware/* .

    remove_old_files

    update_new_files

    echo "Create config directory is ready!" | tee -a $report
}

create_bin(){
    echo "Create bin directory ..." | tee -a $report

    if [ -d $bin_path/$product ] ;then
        echo "The directory : <$bin_path/$product> is already existing!" | tee -a $report
        echo "Skipped create bin directory!" | tee -a $report
    else
        echo "cd $bin_path"
        cd $bin_path

        echo "mkdir -vp $bin_path/$product"
        mkdir -vp $bin_path/$product

        echo "cd $bin_path/$product"
        cd $bin_path/$product

        echo "create symbolic-link to bin/common"
        echo "cp -s ../common/* ."
        cp -s ../common/* .

        # add cli tools
        echo "Create empty cli tools : acquireDefaultConnectionService.sh cli_dut.sh TR069_config.sh"

        echo "echo \"AT_ERROR : this tool is Invalid!\";exit 1" > acquireDefaultConnectionService.sh.TODO
        echo "echo \"AT_ERROR : this tool is Invalid!\";exit 1" > cli_dut.sh.TODO
        echo "echo \"AT_ERROR : this tool is Invalid!\";exit 1" > TR069_config.sh.TODO

        echo "chmod +x acquireDefaultConnectionService.sh.TODO cli_dut.sh.TODO TR069_config.sh.TODO"
        chmod +x acquireDefaultConnectionService.sh.TODO cli_dut.sh.TODO TR069_config.sh.TODO

        echo "Create bin directory is ready!" | tee -a $report

        echo "You must add tools by youself:"  | tee -a $report
        echo "  acquireDefaultConnectionService.sh"  | tee -a $report
        echo "  cli_dut.sh"  | tee -a $report
        echo "  TR069_config.sh"  | tee -a $report

        echo "Create bin directory is ready!" | tee -a $report
    fi
}

create_test_suite(){
    echo "Create test suite directory ..." | tee -a $report

    if [ -d $tsuite_path/$product ] ;then
        echo "The directory : <$tsuite_path/$product> is already existing!" | tee -a $report
        echo "Skipped the creat test suite directory!" | tee -a $report
    else
        echo "cd $tsuite_path"
        cd $tsuite_path

        echo "Create test suite refer to template product's test suite <$tsuite_path/$template_product>"
        echo "cp -r $tsuite_path/$template_product $product"
        cp -r $tsuite_path/$template_product $product

        ##############
        ## Todo: replace the vaiable value of dependency product and firmware
        ##############
        echo "Create test suite directory is ready!" | tee -a $report
    fi
}

echo $split_1 | tee -a $report
create_tcases

echo $split_1 | tee -a $report
create_config

echo $split_1 | tee -a $report
create_bin

echo $split_1 | tee -a $report
create_test_suite
