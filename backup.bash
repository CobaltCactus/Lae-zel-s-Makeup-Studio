#!/bin/bash
# backup.bash: pull all BG3 Mod Project files into a single place for source code management
# by mstephenson6, see guide at https://mod.io/g/baldursgate3/r/git-backups-for-mod-projects
# Edit by TheCobaltCactus to store multiple related mods (zipped to maintain separation) within a single repo.
set -e

#TODO Enter Mod Directory or Directories here
MOD_SUBDIR_NAMES=(
	"LMS_Option_1_a5aa97a9-4359-bbc1-6a3f-7b4beb433fe9"
	"LMS_option_1_nocheeks_50499f90-acc6-4996-1f63-73392807fdca"
	"LMS_option_2_bd288a42-f9ee-637c-f968-c696f878fff7"
	"LMS_option_2_nocheeks_a801e598-76d1-7a52-3b48-b9109c383b63"
	"LMS_option_3_d26e8065-8f7e-586f-614f-ce5875c6a582"
	"LMS_option_3_nocheeks_d202dfd5-d729-b774-f746-3614835157fc"
	"LMS_option_4_160b5ade-ef92-7454-b329-e32cf286cea2"
	"LMS_option_4_nocheeks_816ad0cf-0e8c-e75d-4eeb-84e81b295c85"
	"LMS_option_5_23d7d28a-4ee9-0b6c-70f1-f7cfec7a4797"
	"LMS_option_5_nocheeks_ffe5d9db-8e0b-0bb8-8b86-c663c600ba24"
	"LMS_option_6_039c586f-a236-d03c-dcd0-cd0ae42cc726"
	"LMS_option_6_noforehead_6ca55823-649e-e637-10ed-e4b069cd2892"
	"LMS_option_7_c01de848-77a7-8d0b-dcad-e95358a15a73"
	"LMS_option_7_nocheeks_00e11ce8-1a4f-4e85-cd1c-e6a27c54956d"
	"LMS_option_8_bd4d4f4e-ad86-735d-88f5-bc75a53046c3"
	"LMS_option_8_nocheeks_b2015a70-195e-d2a3-a6a6-334e9d5f08f9"
	"LMS_option_9_965e36c2-8bcd-b2f7-e397-2e7ae94d1d8e"
	"LMS_option_9_nocheeks_991bbe96-f067-a653-c638-6d100add74ac"
	"LMS_option_10_8d1b9261-021b-52e7-29c4-6c08f01c8d23"
	"LMS_option_10_nocheeks_bf7d9fcf-7c04-693d-048c-0f0d9c08d493"
)

#TODO Set this path to the BG3 Data Folder
BG3_DATA="/d/Program Files (x86)/Steam/steamapps/common/Baldurs Gate 3/Data"

SUBDIR_LIST=(
    "Projects"
    "Editor/Mods"
    "Mods"
    "Public"
    "Generated/Public"
)

if [ "${#MOD_SUBDIR_NAMES[@]}" -eq 0 ]; then
    echo "MOD_SUBDIR_NAMES must have at least one value in $(basename "$BASH_SOURCE")"
    exit 1
fi

for MOD_SUBDIR_NAME in "${MOD_SUBDIR_NAMES[@]}"; do
    echo "Processing: $MOD_SUBDIR_NAME"

    COPIED=0
    for subdir in "${SUBDIR_LIST[@]}"; do
        rm -rf "$subdir/$MOD_SUBDIR_NAME"
        SRC_ABS_PATH="$BG3_DATA/$subdir/$MOD_SUBDIR_NAME"
        if [ ! -d "$SRC_ABS_PATH" ]; then
            continue
        fi
        mkdir -p "$subdir"
        cp -a "$SRC_ABS_PATH" "$subdir"
        COPIED=1
    done

    if [ "$COPIED" -eq 0 ]; then
        echo "No mod directories found for '$MOD_SUBDIR_NAME' — skipping."
        continue
    fi

    ARCHIVE="${MOD_SUBDIR_NAME}.tar.gz"
    tar -czf "$ARCHIVE" "${SUBDIR_LIST[@]/%//$MOD_SUBDIR_NAME}" --ignore-failed-read 2>/dev/null || \
        tar -czf "$ARCHIVE" $(for s in "${SUBDIR_LIST[@]}"; do [ -d "$s/$MOD_SUBDIR_NAME" ] && echo "$s/$MOD_SUBDIR_NAME"; done)

    for subdir in "Projects" "Editor" "Mods" "Public" "Generated"; do
        rm -rf "$subdir"
    done
done

git add --all
git commit -m "Backup at $(date)"
git push