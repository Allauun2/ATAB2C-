#!/usr/bin/env python3
"""Report ELF LOAD-segment alignment of every .so inside an AAB/APK.

Google Play requires 16 KB (16384) alignment for apps on Android 15+ devices.
Exits non-zero if any native library is aligned below that, so a bad bundle
fails the build instead of being rejected after upload.
"""
import struct
import sys
import zipfile

REQUIRED = 16384
PT_LOAD = 1


def max_load_alignment(data: bytes):
    """Largest p_align across LOAD segments, or None if not a 64-bit ELF."""
    if data[:4] != b"\x7fELF" or data[4] != 2:  # 2 = ELFCLASS64
        return None
    e_phoff = struct.unpack_from("<Q", data, 0x20)[0]
    e_phentsize = struct.unpack_from("<H", data, 0x36)[0]
    e_phnum = struct.unpack_from("<H", data, 0x38)[0]
    alignments = []
    for i in range(e_phnum):
        off = e_phoff + i * e_phentsize
        p_type = struct.unpack_from("<I", data, off)[0]
        if p_type == PT_LOAD:
            alignments.append(struct.unpack_from("<Q", data, off + 0x30)[0])
    return max(alignments) if alignments else None


def main(archive):
    bad = []
    with zipfile.ZipFile(archive) as z:
        libs = [n for n in z.namelist() if n.endswith(".so")]
        if not libs:
            print(f"No .so files found in {archive}")
            return 1
        for name in sorted(libs):
            align = max_load_alignment(z.read(name))
            if align is None:
                print(f"  skip (not 64-bit ELF): {name}")
                continue
            ok = align >= REQUIRED
            print(f"  {'OK  ' if ok else 'FAIL'} {align:>6} bytes  {name}")
            if not ok:
                bad.append(name)
    if bad:
        print(f"\n{len(bad)} library/libraries are not 16 KB aligned.")
        return 1
    print("\nAll native libraries are 16 KB aligned.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
