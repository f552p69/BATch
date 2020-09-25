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
with open(dir_name+"regions_tibco.yml", 'rt') as inFile:
    try:
        regions.update(yaml.load(inFile, yaml.SafeLoader))
    except yaml.YAMLError as exc:
        print(exc)
        sys.exit(-1)
        
for region_key in regions:
    cur_region=n0dict(regions[region_key])
    if cur_region.has_all(("usr","psw","url","hom")):
        if cur_region.nvl('flg').upper() == "TIBCO":
            subprocess.run([
                "cmd", "/c", "download_tarbz2.bat",
                region_key, 
                cur_region["usr"], 
                cur_region["psw"], 
                cur_region["url"],
                cur_region["hom"] + "/datafiles",
                # "./", # Run6 = 1,501,207
                # ".", # Run7 = 1,506,813 = Dir '.' exists
                # "./*", # Run8 = 1,487,189
                # "\"\"", # Doesn't work
                "*", # Run3 = 1,486,772
                ".",
            ])
