#!/bin/bash
# backup.bash: pull all BG3 Mod Project files into a single place for source code management
# by mstephenson6, see guide at https://mod.io/g/baldursgate3/r/git-backups-for-mod-projects

set -e;

# TODO Set MOD_SUBDIR_NAME here, example:
# MOD_SUBDIRS=(
#   "CircleOfTheSpores_db7e15fd-b2fc-b159-4bbd-1baab34d8c3a"
#   "LMS_Option_1_a5aa97a9-4359-bbc1-6a3f-7b4beb433fe9"
# )
# Look in "D:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\Data\"
# for names of mods you have already started
MOD_SUBDIRS=(
"LMS_Option_1_a5aa97a9-4359-bbc1-6a3f-7b4beb433fe9"
"LMS_option_1_nocheeks_50499f90-acc6-4996-1f63-73392807fdca"
)

# This is the MinGW64 path to a Steam install of the toolkit
BG3_DATA="/d/Program Files (x86)/Steam/steamapps/common/Baldurs Gate 3/Data"

# These are set according to "Understanding the Mod Locations", as of Nov 2024, from
# https://mod.io/g/baldursgate3/r/getting-started-creating-a-new-mod
SUBDIR_LIST=(
	"Projects"
	"Editor/Mods"
	"Mods"
	"Public"
	"Generated/Public"
)

if [ ${#MOD_SUBDIRS[@]} -eq 0 ]; then
  echo "MOD_SUBDIRS must contain at least one folder name in $(basename "$BASH_SOURCE")"
  exit 1
fi

# For each SUBDIR preserve top-level folder structure and copy only requested mod folders.
for subdir in "${SUBDIR_LIST[@]}"; do
  SRC_TOP="$BG3_DATA/$subdir"
  DEST_TOP="$subdir"

  # Only create the top-level folder in repo if at least one requested mod exists there
  mkdir -p "$DEST_TOP"

  for modname in "${MOD_SUBDIRS[@]}"; do
    SRC_PATH="$SRC_TOP/$modname"
    DEST_PATH="$DEST_TOP/$modname"

    if [ -d "$SRC_PATH" ]; then
      # remove existing copy to ensure sync
      rm -rf "$DEST_PATH"
      cp -a "$SRC_PATH" "$DEST_TOP"
    fi
  done
done

git add --all
git commit -m "Backup at $(date)"
git push
