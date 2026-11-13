import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

spec = importlib.util.spec_from_file_location('publisher', Path(__file__).parents[1] / 'scripts/curseforge.py')
publisher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(publisher)


def release_zip(folder, version='0.9.5', interface='16001', extra=True):
    path = Path(folder) / f'ForeverHUD-v{version}.zip'
    with zipfile.ZipFile(path, 'w') as z:
        z.writestr('ForeverHUD/ForeverHUD.toc', f'## Interface: {interface}\n## Version: {version}\n')
        z.writestr('ForeverHUD/Core.lua', '-- core')
        if extra:
            z.writestr('imports/ForeverHUD-Warlock.txt', '!WA:2!x')
            z.writestr('docs/design.md', '# design')
            z.writestr('README.md', '# readme')
    return path


class PublisherTests(unittest.TestCase):
    def test_exact_version(self):
        self.assertEqual(publisher.select_version([{'name': '1.60.1', 'id': 42}], '1.60.1'), 42)

    def test_no_fallback_to_classic(self):
        with self.assertRaises(ValueError):
            publisher.select_version([{'name': '1.15.7', 'id': 42}], '1.60.1')

    def test_ambiguous_version(self):
        with self.assertRaises(ValueError):
            publisher.select_version([{'name': '1.60.1', 'id': 42}] * 2, '1.60.1')

    def test_repacks_only_the_addon_folder(self):
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder) / 'out.zip'
            name = publisher.addon_archive(release_zip(folder), 'v0.9.5', target)
            self.assertEqual(name, '1.60.1')
            with zipfile.ZipFile(target) as z:
                self.assertEqual(sorted(z.namelist()), ['ForeverHUD/Core.lua', 'ForeverHUD/ForeverHUD.toc'],
                                 'imports/, docs/ and README must not reach Interface/AddOns')
            again = Path(folder) / 'again.zip'
            publisher.addon_archive(release_zip(folder), 'v0.9.5', again)
            self.assertEqual(target.read_bytes(), again.read_bytes(), 'Deterministic repack')

    def test_tag_must_match_toc(self):
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(ValueError):
                publisher.addon_archive(release_zip(folder), 'v0.9.4', Path(folder) / 'o.zip')

    def test_only_forever_client(self):
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(ValueError):
                publisher.addon_archive(release_zip(folder, interface='11507'), 'v0.9.5', Path(folder) / 'o.zip')

    def test_untrusted_tag(self):
        for tag in ('../v0.9.5', 'ForeverHUD-v0.9.5', 'v0.9', ''):
            with self.assertRaises(ValueError):
                publisher.check_tag(tag)

    def test_multipart(self):
        with tempfile.TemporaryDirectory() as folder:
            archive = release_zip(folder)
            data, mime = publisher.multipart({'releaseType': 'beta'}, archive)
            self.assertIn(b'name="metadata"', data)
            self.assertIn(b'name="file"', data)
            self.assertIn(archive.read_bytes(), data)
            self.assertTrue(mime.startswith('multipart/form-data; boundary='))

    def test_no_token_redirect(self):
        self.assertIsNone(publisher.NoRedirect().redirect_request(None, None, None, None, None, None))

    def test_project_is_foreverhud(self):
        self.assertEqual(publisher.PROJECT_ID, '1801711')


if __name__ == '__main__':
    unittest.main()
