#!/usr/bin/env sh
set -euf

download_install() {
    set -e
    url=$1
    md5=$2
    filename=$3

    download_path="${version_directory}/${filename}"

    # If the user knows what they're doing, skip all downloads
    if [ "${SKIP_INSTALL:-}" = "true" ]; then
        return
    fi

    # If this pack is up to date, skip downloading it
    if [ "${force_update}" = 0 ] && [ -f "${download_path}.txt" ] && [ "$(cat "${download_path}.txt")" = "${md5}" ]; then
        base_pack_installed=1
        return
    fi

    # If we are updating this pack, all packs after it must also be updated
    force_update=1
    rm -f "${download_path}.txt"

    # If this is the first pack to be installed, delete the entire server folder
    if [ "${base_pack_installed}" = 0 ]; then
        rm -rf "${server_directory}"
    fi

    echo "Downloading ${filename} archive..."
    mkdir -p "${version_directory}"
    curl -#SL -o "${download_path}" "${url}"

    echo "Verifying md5 checksum ${md5}"
    echo "${md5} ${download_path}" | md5sum -c -

    echo "Extracting ${filename} archive..."
    mkdir -p "${server_directory}"
    tar -xf "${download_path}" -C "${server_directory}"

    echo "Removing ${filename} archive"
    rm "${download_path}"

    mkdir -p "${version_directory}"
    echo "${md5}" >"${download_path}.txt"
    base_pack_installed=1
}

server_directory="$1"
version_directory="${server_directory}/.versions"

force_update=0
base_pack_installed=0

# Update to new md5 (same files but compressed with zstd)
if [ -f "${version_directory}/ut2004server_base.txt" ] && [ "$(cat "${version_directory}/ut2004server_base.txt")" = "5f9c999ed8f695a67877018ba6a12607" ]; then
    echo "4de111e1e66a90d32ef59b61195376da" >"${version_directory}/ut2004server_base.txt"
fi

# Install base server with latest patch (3369.2), Epic ECE Bonus Pack, and Bonus Megapack
download_install \
    "https://drive.usercontent.google.com/download?id=1RBHApIf3HU3d-b9lxRJbxVWZj6I6FWc4&export=download&confirm=t" \
    4de111e1e66a90d32ef59b61195376da \
    ut2004server_base
