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
import os

@click.command()
@click.argument("URL_MAP")
@click.argument("SOURCE_DIR")
def main(url_map: str, source_dir: str):
    map_link_to_uid = extract_csv(url_map)
    links_to_xrefs(source_dir, map_link_to_uid)
    remove_index(source_dir)

def extract_csv(url_map) -> dict:
    f = urlopen(url_map)
    lines = [l.decode('utf-8') for l in f.readlines()]
    reader = csv.reader(lines)
    csv_file = dict(reader)
    return csv_file

def links_to_xrefs(source_dir, map_link_to_uid):
    for subdir, dirs, files in os.walk(source_dir):
        for filename in files:
            filepath = subdir + os.sep + filename
            if filepath.endswith(".md"):
                with open(filepath, "rt", encoding='utf-8') as f:
                    text = f.readlines()
                    new_text = []
                    for line in text:
                        for url in map_link_to_uid:
                            uid = map_link_to_uid[url]
                            # Handle both /blob/ and /tree/ links
                            full_blob_url = 'https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/'+url
                            full_tree_url = 'https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/'+url
                            full_uid = 'xref:' + uid
                            line = line.replace(full_blob_url, full_uid)
                            line = line.replace(
                                '← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)', '')
                            line = line.replace(full_tree_url, full_uid)
                        new_text.append(line)
                with open(filepath, "wt", encoding='utf-8') as f:
                    for line in new_text:
                        f.write(line)

def remove_index(source_dir):
    lines = open(source_dir + 'README.md').readlines()
    f = open(source_dir + 'README.md', 'w')
    for line in lines:
        if "## Index" in line:
            break
        else:
            f.writelines(line)
    f.close()
    
if __name__ == "__main__":
    main()
