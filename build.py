import logging
import shutil
import subprocess
import sys
import os

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("build")

# Note: these paths are for local Windows installs.  All of these tools
# can be installed under Linux as well, but these paths will need to change.
assembler = ".\\merlin32\\windows\\merlin32.exe"
assembler_libdir = ".\\merlin32\\library\\"
ciderpresscli = ".\\ciderpress\\cp2.exe"
fhpack = ".\\fhpack\\fhpackd.exe"

# Check for all the tools to be present
prerequisites = True
for name in (assembler, assembler_libdir, ciderpresscli, ):
    if not os.path.exists(name):
        log.warning(f"required build tool: {name} could not be found.")
        prerequisites = False
if not prerequisites:
    log.error("Please install necessary build tools and rerun the build process.")
    sys.exit(1)
for name in (fhpack, ):
    if not os.path.exists(name):
        log.warning(f"optional build tool: {name} could not be found and will not be used.")

# Set the version number and start the build process
version = "1.4.1"  

# Burn the version number into the help screen: HELP_SRC.S -> HELP.S 
log.info("Generating 6502 source code...")
with open("HELP_SRC.S", "r") as fp:
    text = fp.read()
    with open("HELP.S", "w") as out:
        text = text.replace("V_NUM", version)
        out.write(text)

files = {
    "DRAWTAB.S": 0x4E00,
    "GAME1.S": 0x7400,
    "GAME2.S": 0x7A00,
    "IO2.S": 0x9000,
    "OPENING2.S": 0x8000,
    "PAC.S": 0x0800,
    "PRE.S": 0x9700,   # Park of the editors, not core game
    "WEAPONS.S": 0x7200,
    "DECOMP_IMG.S": 0x4000,
    "LOADER.S": 0x2000,
    "HELP.S": 0x7000,
    "READ_DOCS.S": 0x2000,  # stand alone documentation reader READ.DOCS.SYS (DIAFLW.DOCS,TXT)
}

log.info("Assembling 6502 source code...")
# compile sources
for name, address in files.items():
    cmd = [assembler, assembler_libdir, name]
    log.info(f"Assembling: {name} @ ${address:X}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        log.error(f"assembling: {name}: {result.stdout}")
        sys.exit(1)
        
log.info("Compressing splash screen images...")
if not os.path.exists(os.path.join("bin","diaflw_splash.fgr")):
    cmd = [fhpack, "-c", "diaflw_splash.hgr", "bin/diaflw_splash.fgr"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        log.error(f"compressing: diaflw_splash.hgr")
        sys.exit(1)
    log.info("Generated: bin/diaflw_splash.fgr")
if not os.path.exists(os.path.join("bin","diaflw_play.fgr")):
    cmd = [fhpack, "-c", "diaflw_play.hgr", "bin/diaflw_play.fgr"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        log.error(f"compressing: diaflw_play.hgr")
        sys.exit(1)
    log.info("Generated: bin/diaflw_play.fgr")
    
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

log.info("Building DIAFLW.SYSTEM(SYS#ff) file...")

# Build 'DIAFLW.SYSTEM,TSYS' from bins
with open('DIAFLW_SYSTEM_orig.bin', 'rb') as fp:
    data = bytearray(fp.read())

for name, addr in bins.items():
    log.info(f"Loading {name} at {addr:04X}")
    with open(name, "rb") as f:
        local = bytearray(f.read())
    offset = addr - 0x2000
    length = len(local)
    data[offset:offset+length] = local

outname = "DIAFLW.SYSTEM#ff2000"
with open(outname, "wb") as fp:
    fp.write(data)
log.info(f"Wrote system file: {outname}")

log.info("Building DIAFLW.DOCS(TXT#04) file...")
# Build docs file
with open("diaflw_docs.txt", "r") as fp:
    text = fp.read()
    with open("SYSTEM/DIAFLW.DOCS#040000", "w") as out:
        text = text.replace("V_NUM", version)
        out.write(text)

log.info("Building .2mg disk image...")
# Create a release .2mg image
rel_filename = "DIAFLW_Release.2mg"
try:
    os.remove(rel_filename)
except Exception:
    pass
cmd = [ciderpresscli, "create-disk-image", rel_filename, "800K", "prodos"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
log.info(f"Created release disk image: {result.stdout} {result.stderr}")
cmd = [ciderpresscli, "rename", rel_filename, ":", f"DIAFLW_{version}"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
log.info(f"Renamed release disk image: {result.stdout} {result.stderr}")

# Copy system files - PRODOS, BASIC...  
try:
    os.remove("SYSTEM/_FileInformation.txt")
except Exception:
    pass
cmd = [ciderpresscli, "add", "--strip-paths", "DIAFLW_Release.2mg", "SYSTEM"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
log.info(f"System files added to disk image: {result.stdout} {result.stderr}")
# and DIAFLW.SYSTEM
cmd = [ciderpresscli, "add", "--strip-paths", "DIAFLW_Release.2mg", outname]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
log.info(f"System file added to disk image: {result.stdout} {result.stderr}")

# Copy scenarios
cmd = [ciderpresscli, "add", rel_filename, "SCENARIOS"]
result = subprocess.run(cmd, capture_output=True, text=True, check=True)
log.info(f"Scenarios added to disk image: {result.stdout} {result.stderr}")
# rename them to include trailing '.'
for name in os.listdir("SCENARIOS"):
    if os.path.isdir(os.path.join("SCENARIOS", name)):
        cmd = [ciderpresscli, "rename", rel_filename, f"SCENARIOS/{name}", f"SCENARIOS/{name}."]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        log.info(f"Renamed: SCENARIOS/{name}")

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
        log.info(f"Imported: basic/{name} as {root}")


# Build 'READ.DOCS,TSYS' from 'bin/PRG.BIN'

log.info(f"Build v{version} complete.")
 