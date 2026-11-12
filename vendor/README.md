# Build-only codec dependencies

These files are used offline to read/write the LibSerialize → raw Deflate → print-encoding format accepted by ForeverAuras. They are not loaded by the companion addon and are not included in its ZIP.

- **LibSerialize**, Ross Nichols — MIT license in the file header. This copy includes ForeverAuras' private-instance registration adjustment.
- **LibDeflate**, Haoqian He — zlib license in the file header.
- **LibStub**, Kaelten and contributors — public domain, as stated in the file header.

Copies were taken on 2026-11-09 from the user's installed ForeverAuras 1.3.5 `Libs/` directory. See the upstream [ForeverAuras repository](https://github.com/neroxrw/foreverauras/tree/main/ForeverAuras/Libs) for corresponding source and [LibSerialize](https://github.com/rossnichols/LibSerialize), [LibDeflate](https://github.com/SafeteeWoW/LibDeflate), and [LibStub](https://www.wowace.com/projects/libstub) for the original projects. Their existing notices are preserved.

Packaging changes: line endings were normalized to LF and trailing whitespace removed. No library logic was changed by ForeverHUD.
