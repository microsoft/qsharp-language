#!/bin/env python
# -*- coding: utf-8 -*-
##
# replace_links.py: replaces the relevant links with uid cross references.  
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
##

"""
Replaces GitHub links with uid cross references for the files specified 
in a uid-map.csv file. This script is used to create a usable copy of 
the files for the documentation repository.

"""
import click 
import csv
from urllib.request import urlopen

@click.command()
@click.argument("URL_MAP")
@click.argument("SOURCE_DIR")
def main(url_map : str, source_dir: str):
    map_link_to_uid = extract_csv(url_map)
    links_to_xrefs(source_dir, map_link_to_uid)

def extract_csv(url_map) -> dict:
    f = urlopen(url_map)
    lines = [l.decode('utf-8') for l in f.readlines()]
    reader = csv.reader(lines)
    csv_file = dict(reader)
    return csv_file

def links_to_xrefs(source_dir, map_link_to_uid):
    for path in map_link_to_uid:
        with open(source_dir + path, "rt", encoding='utf-8') as f:
            text = f.readlines()
            new_text = []
            for line in text:
                for url in map_link_to_uid:
                    uid = map_link_to_uid[url]
                    full_url = 'https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/'+url
                    full_uid = 'xref:'+ uid
                    line = line.replace(full_url, full_uid)
                    line = line.replace('← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)','')
                new_text.append(line)
        with open(source_dir + path, "wt", encoding='utf-8') as f:
            for line in new_text:
                f.write(line)
                
if __name__ == "__main__":
    main()
