import shutil
import subprocess
import os

assembler = ".\\Merlin32_v1.2_b2\\Windows\\Merlin32.exe"
assembler_libdir = ".\\Merlin32_v1.2_b2\\Library\\"
ciderpresscli = ".\\ciderpress\\cp2.exe"
version = "1.1.4"  # Also HELP.S

files = {
    "DRAWTAB.S": 0x4E00,  # 0x9600,
    "GAME1.S": 0x7400,
    "GAME2.S": 0x7A00,
    "IO2.S": 0x9000,
    "OPENING2.S": 0x8000,
    "PAC.S": 0x0800,
    "PRE.S": 0x9700,
    "PRG.S": 0x2000,   # stand alone documentation reader READ.DOCS.SYS (DIAFLW.AWP)
    "WEAPONS.S": 0x7200,
    "DECOMP_IMG.S": 0x4000,
    "LOADER.S": 0x2000,
    "HELP.S": 0x7000,
}

# compile sources
for name, address in files.items():
    cmd = [assembler, assembler_libdir, name]
    print(f"Assembling: {name} @ ${address:X}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error assembling: {name}: {result.stdout}")
        
# Build splash screen image
# cmd = [".\\tohgr.exe", "hgr", "-atkin", "diaflw_splash.png"]
# result = subprocess.run(cmd, capture_output=True, text=True, check=True)
cmd = [".\\fhpack.exe", "-c", "diaflw_splash.hgr", "bin/diaflw_splash.fgr"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
cmd = [".\\fhpack.exe", "-c", "diaflw_play.hgr", "bin/diaflw_play.fgr"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)

    
bins = {
    "bin/LOADER.BIN": 0x2000,
    "bin/BIGFONT#061c00": 0x5C00,
    "bin/SOUNDS#068900": 0x3900,     # reloc=0x8900
    "bin/LOOKTBLS#060C00": 0x2E00,   # reloc=0x0E00
    "bin/DECOMP_IMG.BIN": 0x4000,
    "bin/diaflw_splash.fgr": 0x4100, 
    "bin/diaflw_play.fgr": 0x4A00,   
    "bin/HELP.BIN": 0x7000,          # this is overwritten after moved to text
    "bin/GAME1.BIN": 0x6400,         # reloc=0x7400,
    "bin/GAME2.BIN": 0x6A00,         # reloc=0x7A00,
    "bin/IO2.BIN": 0x2100,           # reloc=0x9000,
    "bin/OPENING2.BIN": 0x3000,      # reloc=0x8000,
    "bin/PAC.BIN": 0x2800,           # reloc=0x0800,
    "bin/WEAPONS.BIN": 0x6200,       # reloc=0x7200,
    "bin/DRAWTAB.BIN": 0x4E00,       # reloc=0x4E00,
}
'''
    "PRE.S": 0x9700,   # prefix support for editors
    "PRG.S": 0x2000,   # stand alone documentation reader READ.DOCS.SYS (DIAFLW.AWP)
'''

# 2000 - LOADER.S
#     Reads from 2800-3000 and stores to 0800-1000
#     Reads from 2100-2800 and stores to 9000-9800
#     Reads from 3000-4000 and stores to 8000-9000
#     Reads from 6000-7000 and stores to 7000-8000
#     Paint the text page from 7000-7400
#     JMP 8000


# Build 'DIAFLW.SYSTEM,TSYS' from bins
with open('DIAFLW_SYSTEM_orig.bin', 'rb') as fp:
    data = bytearray(fp.read())

for name, addr in bins.items():
    print(f"Loading {name} at {addr:04X}")
    with open(name, "rb") as f:
        local = bytearray(f.read())
    offset = addr - 0x2000
    length = len(local)
    data[offset:offset+length] = local

outname = "DIAFLW.SYSTEM#ff2000"
with open(outname, "wb") as fp:
    fp.write(data)
print(f"Wrote system file: {outname}")

# use CiderPress II CLI to place the file into the testing IMG
cmd = [ciderpresscli, "add", "--strip-paths", "--overwrite", "disks/Testing.2mg", outname]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
print(f"Updated testing 2mg file: {result.stdout} {result.stderr}")

# Create a release .2mg image
rel_filename = "DIAFLW_Release.2mg"
try:
    os.remove(rel_filename)
except Exception:
    pass
cmd = [ciderpresscli, "create-disk-image", rel_filename, "800K", "prodos"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
print(f"Created release disk image: {result.stdout} {result.stderr}")
cmd = [ciderpresscli, "rename", rel_filename, ":", f"DIAFLW_{version}"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
print(f"Renamed release disk image: {result.stdout} {result.stderr}")

# Copy system files - PRODOS, BASIC...  
cmd = [ciderpresscli, "add", "--strip-paths", "DIAFLW_Release.2mg", "SYSTEM"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
print(f"System files added to disk image: {result.stdout} {result.stderr}")
# and DIAFLW.SYSTEM
cmd = [ciderpresscli, "add", "--strip-paths", "DIAFLW_Release.2mg", outname]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
print(f"System file added to disk image: {result.stdout} {result.stderr}")

# Copy scenarios
cmd = [ciderpresscli, "add", rel_filename, "SCENARIOS"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
print(f"Scenarios added to disk image: {result.stdout} {result.stderr}")
# rename them to include trailing '.'
for name in os.listdir("SCENARIOS"):
    if os.path.isdir(os.path.join("SCENARIOS", name)):
        cmd = [ciderpresscli, "rename", rel_filename, f"SCENARIOS/{name}", f"SCENARIOS/{name}."]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"Renamed: SCENARIOS/{name}")

for name in os.listdir("basic"):
    if name.upper().endswith(".ABAS"):
        root = os.path.splitext(name)[0]
        try:
            os.remove(os.path.join("basic", root))
        except Exception:
            pass
        # make a temp copy to rename the file so the import is clean
        shutil.copy(os.path.join("basic", name), os.path.join("basic", root))
        cmd = [ciderpresscli, "import", "--strip-paths", rel_filename, "bas",  f"basic/{root}"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        os.remove(os.path.join("basic", root))
        print(f"Imported: basic/{name} as {root}")


# Build 'READ.DOCS,TSYS' from 'bin/PRG.BIN'
 