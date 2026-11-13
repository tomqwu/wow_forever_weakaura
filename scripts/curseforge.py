#!/usr/bin/env python3
"""Publish an existing GitHub release to CurseForge through the official WoW upload API.

Adapted from the approach used by wow_forever_classmate (its scripts/curseforge.py):
dry-run first, the game version derived from the TOC interface and matched by exact
name, no retry of the non-idempotent upload, and an upload receipt stored on the
GitHub release so a rerun never uploads twice.

ForeverHUD's release ZIP also carries imports/, docs/, preview/ and the README for
GitHub users. The CurseForge app would unpack those into Interface/AddOns, so this
publisher repacks only the ForeverHUD/ addon folder for CurseForge.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import urllib.error
import urllib.request
import uuid
import zipfile

API = 'https://wow.curseforge.com/api'
ADDON = 'ForeverHUD'
PROJECT_ID = '1801711'
TAG = re.compile(r'v(\d+\.\d+\.\d+)')
# Fixed entry timestamp, as in scripts/build.py, so equal input gives equal bytes.
ZIP_DATE = (2026, 1, 1, 0, 0, 0)


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None  # Never forward the API token to a redirect destination.


def api_request(path, token, data=None, content_type=None):
    headers = {'X-Api-Token': token, 'Accept': 'application/json',
               'User-Agent': 'ForeverHUD-release/1.0'}
    if content_type:
        headers['Content-Type'] = content_type
    request = urllib.request.Request(API + path, data=data, headers=headers)
    try:
        with urllib.request.build_opener(NoRedirect).open(request, timeout=90) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        raise RuntimeError(f'CurseForge API returned HTTP {error.code}; check the token, project and game version.') from None
    except (urllib.error.URLError, TimeoutError):
        raise RuntimeError('CurseForge connection failed. If an upload had started, check the project Files before retrying.') from None


def check_tag(tag):
    match = TAG.fullmatch(tag or '')
    if not match:
        raise ValueError('Release tag must have the form vX.Y.Z')
    return match[1]


def addon_archive(release_zip, tag, target):
    """Repack only ForeverHUD/ from the release ZIP; return its CurseForge game version name."""
    version = check_tag(tag)
    with zipfile.ZipFile(release_zip) as package:
        names = [n for n in package.namelist() if n.startswith(ADDON + '/') and not n.endswith('/')]
        if not names or any('..' in n.split('/') for n in package.namelist()):
            raise ValueError(f'Expected a release ZIP with a clean {ADDON}/ folder')
        toc = package.read(f'{ADDON}/{ADDON}.toc').decode('utf-8-sig')
        found = re.search(r'^## Version:\s*(\d+\.\d+\.\d+)\s*$', toc, re.M)
        interface = re.search(r'^## Interface:\s*(\d+)\s*$', toc, re.M)
        if not found or found[1] != version or not interface:
            raise ValueError('ZIP version/interface does not match the selected release')
        value = int(interface[1])
        if value // 10000 != 1 or (value % 10000) // 100 != 60:
            raise ValueError('This publisher only targets the Forever 1.60 client family')
        with zipfile.ZipFile(target, 'w') as out:
            for name in sorted(names):
                info = zipfile.ZipInfo(name, date_time=ZIP_DATE)
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o644 << 16
                out.writestr(info, package.read(name), compresslevel=9)
    return f'{value // 10000}.{(value % 10000) // 100}.{value % 100}'


def select_version(versions, name):
    matches = [v for v in versions if v.get('name') == name]
    if len(matches) != 1 or not isinstance(matches[0].get('id'), int):
        raise ValueError(f'CurseForge must expose exactly one game version named {name}; found {len(matches)}. Refusing to label this as another WoW version.')
    return matches[0]['id']


def multipart(metadata, archive):
    boundary = 'ForeverHUD' + uuid.uuid4().hex
    data = (f'--{boundary}\r\nContent-Disposition: form-data; name="metadata"\r\n'
            'Content-Type: application/json\r\n\r\n').encode()
    data += json.dumps(metadata).encode() + b'\r\n'
    data += (f'--{boundary}\r\nContent-Disposition: form-data; name="file"; '
             f'filename="{archive.name}"\r\nContent-Type: application/zip\r\n\r\n').encode()
    data += archive.read_bytes() + f'\r\n--{boundary}--\r\n'.encode()
    return data, f'multipart/form-data; boundary={boundary}'


def gh(*args):
    return subprocess.check_output(['gh', *args], text=True)


def summary(text):
    path = os.environ.get('GITHUB_STEP_SUMMARY')
    if path:
        with open(path, 'a') as handle:
            handle.write(text + '\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag', required=True)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    version = check_tag(args.tag)
    token = os.environ.get('CURSE_FORGE', '')
    project = os.environ.get('CURSEFORGE_PROJECT_ID', '')
    if not token:
        raise ValueError('Missing GitHub Actions secret CURSE_FORGE (a CurseForge API token)')
    if project != PROJECT_ID:
        raise ValueError(f'Set repository variable CURSEFORGE_PROJECT_ID to {PROJECT_ID} (ForeverHUD)')
    repo = os.environ['GITHUB_REPOSITORY']
    release = json.loads(gh('release', 'view', args.tag, '--repo', repo, '--json', 'assets,body,isDraft,url'))
    if release['isDraft']:
        raise ValueError('Publish the GitHub release before uploading to CurseForge')
    asset = f'{ADDON}-v{version}.zip'
    if sum(a['name'] == asset for a in release['assets']) != 1:
        raise ValueError(f'Expected exactly one {asset} in the release')
    folder = Path('dist/curseforge')
    folder.mkdir(parents=True, exist_ok=True)
    gh('release', 'download', args.tag, '--repo', repo, '--pattern', asset, '--dir', str(folder), '--clobber')
    archive = folder / f'{ADDON}-{version}.zip'
    name = addon_archive(folder / asset, args.tag, archive)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    receipt_name = f'curseforge-{args.tag}.json'
    if any(a['name'] == receipt_name for a in release['assets']):
        gh('release', 'download', args.tag, '--repo', repo, '--pattern', receipt_name, '--dir', str(folder), '--clobber')
        receipt = json.loads((folder / receipt_name).read_text())
        if receipt['sha256'] != digest or str(receipt['projectId']) != project:
            raise ValueError('Existing upload receipt does not match the ZIP/project; review manually')
        print(f'Already uploaded: CurseForge file {receipt["fileId"]}; skipped.')
        return
    version_id = select_version(api_request('/game/versions', token), name)
    print(f'Validated {archive.name} (ForeverHUD/ only); CurseForge game version {name} = {version_id}.')
    if args.dry_run:
        print('Dry run complete; no upload performed.')
        summary(f'## CurseForge dry run\n\n{archive.name}, WoW {name} (id {version_id}). Nothing uploaded.')
        return
    metadata = {'changelog': release['body'] or release['url'], 'changelogType': 'markdown',
                'displayName': f'ForeverHUD {version}', 'gameVersions': [version_id], 'releaseType': 'beta'}
    data, content_type = multipart(metadata, archive)
    # Deliberately no retry: the upload POST is not idempotent.
    result = api_request(f'/projects/{project}/upload-file', token, data, content_type)
    file_id = result.get('id')
    if not isinstance(file_id, int) or file_id <= 0:
        raise RuntimeError('Upload response lacked a file ID; check CurseForge Files before retrying.')
    receipt_path = folder / receipt_name
    receipt_path.write_text(json.dumps({'projectId': int(project), 'fileId': file_id, 'tag': args.tag,
                                        'sha256': digest, 'gameVersionId': version_id}, indent=2) + '\n')
    print(f'Upload accepted: CurseForge project {project}, file {file_id}. Moderation may still be pending.')
    try:
        gh('release', 'upload', args.tag, str(receipt_path), '--repo', repo)
    except subprocess.CalledProcessError:
        raise RuntimeError(f'Upload succeeded (file {file_id}) but saving the GitHub receipt failed. Do not rerun before checking CurseForge.') from None
    summary(f'## CurseForge upload\n\nProject {project}, file {file_id}: ForeverHUD {version} (beta), WoW {name}.\n\n'
            'CurseForge may still be reviewing it. Archive older files in the author dashboard once this one is approved.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, RuntimeError, KeyError, zipfile.BadZipFile) as error:
        print(f'Error: {error}', file=sys.stderr)
        sys.exit(1)
