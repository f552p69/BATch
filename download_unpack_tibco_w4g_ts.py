import sys
import os
import yaml
import subprocess
from n0struct import *

dir_name = "R:\\audit\\"
regions = {}
with open(dir_name+"regions_readonly.yml", 'rt') as inFile:
    try:
        regions = yaml.load(inFile, yaml.SafeLoader)
    except yaml.YAMLError as exc:
        print(exc)
        sys.exit(-1)
with open(dir_name+"regions_fullaccess.yml", 'rt') as inFile:
    try:
        regions.update(yaml.load(inFile, yaml.SafeLoader))
    except yaml.YAMLError as exc:
        print(exc)
        sys.exit(-1)
        
for region_key in regions:
    cur_region=n0dict(regions[region_key])
    if cur_region.has_all(("usr","psw","url","hom")):
        if cur_region.nvl('flg').upper() == "TIBCO":
            print("*"*50)
            print("*** "+region_key)
            print("*"*50)
            subprocess.run([
                "cmd", "/c", "download_tarbz2.bat",
                region_key, 
                cur_region["usr"], 
                cur_region["psw"], 
                cur_region["url"],
                cur_region["hom"] + "/datafiles",
                "./*/defaultVars/",
                ".",
                "DOWNLOAD_AND_UNPACK_AT_THE_SAME_MOMENT",
            ])
        else:
            print("="*50)
            print("=== "+region_key)
            print("="*50)
            subprocess.run([
                "cmd", "/c", "download_tarbz2.bat",
                region_key, 
                cur_region["usr"], 
                cur_region["psw"], 
                cur_region["url"],
                cur_region["hom"],
                "./*/w4gateversion.txt " # W4G only
                    + "./*/tsversion.txt " # TS UFX only
                    + "./*/conf/server.xml " # W4G & TS UFX
                    + "./*/webapps/*/WEB-INF/config/work/ows-application* " # W4G only
                    + "./*/webapps/*/WEB-INF/config/work/license-options.xml " # W4G only
                    + "./*/webapps/*/WEB-INF/config/work/zpk-map.xslt " # W4G only
                    + "./*/webapps/*/WEB-INF/conf/node.properties " # TS UFX only
                    # + "./*/webapps/*/WEB-INF/lib/tibjms*.jar " # W4G & TS UFX
                ,
                ".",
                "DOWNLOAD_AND_UNPACK_AT_THE_SAME_MOMENT",
            ])
            print("-"*50)
            print("--- "+region_key+".tibjms_sizes")
            print("-"*50)
            subprocess.run([
                "cmd", "/c", "run_remotely.bat",
                region_key, 
                cur_region["usr"], 
                cur_region["psw"], 
                cur_region["url"],
                'find ' + cur_region["hom"] +' -name tibjms.jar -exec wc -c {} + | sort | grep -v "" total""'
                    .replace("\"","_DQT_").replace(" ","_SPC_").replace("|","_TUB_"),
                region_key+".tibjms_sizes",
            ])
            