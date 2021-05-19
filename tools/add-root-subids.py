#!/usr/bin/env python3

def add_subid(baseid: str, filename: str):
    mapid = 100000
    countid = 65536

    with open(filename, "r") as f:
        for line in f:
            line_baseid, line_mapid, line_countid = line.split(":")
            line_mapid = int(line_mapid)
            line_countid = int(line_countid)

            if line_baseid == baseid:
                return

            mapid = max(mapid, line_mapid + line_countid)

    with open(filename, "a") as f:
        f.write(f"{baseid}:{mapid}:{countid}\n")

add_subid("root", "/etc/subuid")
add_subid("root", "/etc/subgid")
