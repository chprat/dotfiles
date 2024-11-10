#!/usr/bin/env python3

import argparse
import json
import os.path
import re
import subprocess
import sys
import urllib.request


def read_packages():
    """Read package information from file"""
    package_list = []
    with open('gh.pkg', 'r') as packages:
        for package in packages:
            short_url, version = package.split()
            package_name = short_url.split('/')[1]

            package_list.append({
                'short_url': short_url,
                'version': version,
                'package_name': package_name,
            })
        return package_list


def download_asset(short_url, id, file_name):
    """Download a release asset"""
    url = f'https://api.github.com/repos/{short_url}/releases/assets/{id}'
    request = urllib.request.Request(
        url=url,
        headers={"Accept": "application/octet-stream"}
    )
    try:
        with urllib.request.urlopen(request) as url:
            data = url.read()
            with open(file_name, 'wb') as file:
                file.write(data)
    except urllib.error.HTTPError as e:
        sys.exit(f'{url} returned error {e}')
    except urllib.error.URLError as e:
        sys.exit(f'{url} returned error {e}')


def get_asset_info(short_url, id):
    """Get the id of a release asset (linux x86_64 [musl])"""
    url = f'https://api.github.com/repos/{short_url}/releases/{id}/assets'
    try:
        with urllib.request.urlopen(url) as url:
            assets = list({'id': elem['id'], 'name': elem['name']} for elem in json.load(url))
            linux = [v for v in assets if 'linux'.casefold() in v['name'].casefold()]
            x86_64 = [v for v in linux if 'x86_64'.casefold() in v['name'].casefold()]
            if len(x86_64) == 1:
                return x86_64[0]
            if len(x86_64) == 0:
                x86_64 = [v for v in linux if 'amd64'.casefold() in v['name'].casefold()]
                if len(x86_64) == 1:
                    return x86_64[0]
            musl = [v for v in x86_64
                    if 'musl'.casefold() in v['name'].casefold()]
            if len(musl) == 1:
                return musl[0]
            elif len(musl) > 1:
                targz = [v for v in musl if v['name'].casefold().endswith('.tar.gz')]
                if len(targz) == 1:
                    return targz[0]
            else:
                sys.exit(f'No unique file found for {short_url} available: {x86_64}')

    except urllib.error.HTTPError as e:
        sys.exit(f'{url} returned error {e}')
    except urllib.error.URLError as e:
        sys.exit(f'{url} returned error {e}')


def get_release_id(short_url, version):
    """Get the release id of the release"""
    url = f'https://api.github.com/repos/{short_url}/releases/tags/{version}'
    try:
        with urllib.request.urlopen(url) as url:
            return json.load(url)['id']
    except urllib.error.HTTPError as e:
        sys.exit(f'{url} returned error {e}')
    except urllib.error.URLError as e:
        sys.exit(f'{url} returned error {e}')


def get_release_tag(short_url, version):
    """Get the release tag name of the release"""
    url = f'https://api.github.com/repos/{short_url}/releases?per_page=100'
    try:
        with urllib.request.urlopen(url) as url:
            tags = list(elem['tag_name'] for elem in json.load(url))
            tag = [v for v in tags if version in v]
            return tag[0]
    except urllib.error.HTTPError as e:
        sys.exit(f'{url} returned error {e}')
    except urllib.error.URLError as e:
        sys.exit(f'{url} returned error {e}')


def get_local_version(name):
    """Get the version of the installed program"""
    if check_installed(name):
        path = get_install_path(name)
        command = [path, '--version']
        cmd_output = subprocess.run(command,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE,
                                    text=True)
        if (cmd_output.returncode == 0):
            if name == 'lazygit':
                version_field = cmd_output.stdout.split(', ')[3]
                version = version_field.split('=')[1]
            elif name == 'act':
                version = cmd_output.stdout.split()[2]
            elif name == 'fzf':
                version = cmd_output.stdout.split()[0]
            else:
                version = cmd_output.stdout.split()[1]
        else:
            sys.exit(f'Running {name} returned {cmd_output.returncode}: {cmd_output.stderr}')
        return version
    else:
        return '0'


def check_installed(name):
    """Check if the program is installed"""
    path = get_install_path(name)
    exists = os.path.exists(path)
    return exists


def get_install_path(name):
    """Get the install path of the program"""
    path = os.path.expanduser(f'~/.local/bin/{name}')
    return path


def get_latest_release_tag(short_url):
    """Get the latest release of a program"""
    url = f'https://api.github.com/repos/{short_url}/releases/latest'
    try:
        with urllib.request.urlopen(url) as url:
            tag = re.search(r'\d*\.\d*\.\d*',
                            json.load(url)['tag_name']).group()
            return tag
    except urllib.error.HTTPError as e:
        sys.exit(f'{url} returned error {e}')
    except urllib.error.URLError as e:
        sys.exit(f'{url} returned error {e}')


def extract_program(file_name, package_name):
    install_path = os.path.expanduser('~/.local/bin/')
    base_cmd = f'tar xf {file_name} -C {install_path}'.split()

    if package_name == 'lazygit' or package_name == 'act' or package_name == 'fzf':
        base_cmd.append(f'{package_name}')
    elif package_name == 'yazi':
        base_file_name = file_name.replace('.zip', '')
        ar_path = f'{base_file_name}/{package_name}'
        command = f'unzip -j {file_name} {ar_path} -d {install_path}'
        base_cmd = command.split()
    else:
        base_cmd.append('--strip-components=1')
        base_file_name = file_name.replace('.tar.gz', '')
        base_cmd.append(f'{base_file_name}/{package_name}')

    cmd_output = subprocess.run(base_cmd)
    if cmd_output.returncode != 0:
        sys.exit(f'Running tar returned {cmd_output.returncode}: {cmd_output.stderr}')

    if package_name == 'mdcat':
        if not check_installed('mdless'):
            less_name = get_install_path('mdless')
            mdcat_name = get_install_path('mdcat')
            os.symlink(mdcat_name, less_name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="GitHub package manager")
    parser.add_argument('action', choices=['download', 'update'],
                        help='action the script should perform')
    args = parser.parse_args()

    packages = read_packages()

    if args.action == 'download':
        for package in packages:
            local_version = get_local_version(package['package_name'])
            if local_version != package['version']:
                pn = package['package_name']
                pv = package['version']
                plv = local_version
                print(f'Installed version for {pn} differs (expected {pv}, installed {plv})')
                tag = get_release_tag(package['short_url'], package['version'])
                release_id = get_release_id(package['short_url'], tag)
                asset_info = get_asset_info(package['short_url'], release_id)
                download_asset(package['short_url'], asset_info['id'], asset_info['name'])
                extract_program(asset_info['name'], package['package_name'])
                os.remove(asset_info['name'])

    if args.action == 'update':
        for package in packages:
            remote_version = get_latest_release_tag(package['short_url'])
            if remote_version != package['version']:
                pn = package['package_name']
                pv = package['version']
                prv = remote_version
                print(f'New version available for {pn} (current {pv}, new {prv})')
                with open('gh.pkg', 'r') as file:
                    lines = file.readlines()

                with open('gh.pkg', 'r') as file:
                    data = file.read()

                find_string = f"{package['short_url']} {package['version']}"
                replace_string = f"{package['short_url']} {remote_version}"
                data = data.replace(find_string, replace_string)

                with open('gh.pkg', 'w') as file:
                    file.write(data)

                command = 'git commit gh.pkg -m'.split()
                command.append(f"chore: Update {package['package_name']} to {remote_version}")
                subprocess.run(command)
            else:
                print(f"No new version available for {package['package_name']}")
