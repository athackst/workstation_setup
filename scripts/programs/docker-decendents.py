#!/usr/bin/python3

# md
# ## docker-decendents
#
# Finds all decendents of a docker image.
#
# ### Usage
#
# ```sh
# docker_descendants <image_id> ...
# ```
# /md

import argparse
import docker


def find_img(img_idx, id):
    try:
        return img_idx[id]
    except KeyError:
        for k, v in img_idx.items():
            if k.rsplit(":", 1)[-1].startswith(id):
                return v
    raise RuntimeError("No image with ID: %s" % id)


def get_children(img_idx):
    rval = {}
    for img in img_idx.values():
        p_id = img.attrs["Parent"]
        rval.setdefault(p_id, set()).add(img.id)
    return rval


def print_descendants(img_idx, children_map, img_id, indent=0):
    children_ids = children_map.get(img_id, [])
    for id in children_ids:
        child = img_idx[id]
        print(" " * indent, id, child.tags)
        print_descendants(img_idx, children_map, id, indent=indent+2)


def main(args):
    client = docker.from_env()
    img_idx = {_.id: _ for _ in client.images.list(all=True)}
    img = find_img(img_idx, args.id)
    children_map = get_children(img_idx)
    print_descendants(img_idx, children_map, img.id)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("id", metavar="IMAGE_ID")
    main(parser.parse_args())
