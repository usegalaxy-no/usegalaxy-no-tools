MODE=install
PRODUCTION_URL=https://test.usegalaxy.no
PRODUCTION_API_KEY=ADD-YOUR-KEY-HERE


for TOOL_FILE in tmp/*; do
    FILE_NAME=$(basename $TOOL_FILE)

    TOOL_REF=$(echo $FILE_NAME | cut -d'.' -f 1);
    TOOL_NAME=$(echo $TOOL_REF | cut -d '@' -f 1);
    REQUESTED_REVISION=$(echo $TOOL_REF | cut -d '@' -f 2); # TODO: Parsing from file name for revision and tool name is not good.  Fix.
    OWNER=$(grep -oE "owner: .*$" "$TOOL_FILE" | cut -d ':' -f 2 | xargs);
    TOOL_SHED_URL=$(grep -oE "tool_shed_url: .*$" "$TOOL_FILE" | cut -d ':' -f 2 | xargs);
    [ ! $TOOL_SHED_URL ] && TOOL_SHED_URL="toolshed.g2.bx.psu.edu"; # default value
    SECTION_LABEL=$(grep -oE "tool_panel_section_label: .*$" "$TOOL_FILE" | cut -d ':' -f 2 | xargs);

    # If either [FORCE] in the commit message or [SKIP_TESTS] in the file header, skip tests for this tool
    if [ "$(grep '\[SKIP_TESTS\]' $TOOL_FILE)" ] || [ $FORCE = 1 ]; then
      SKIP_TESTS=1
    else
      SKIP_TESTS=0
    fi

    # Find out whether tool/owner combination already exists on galaxy.  This makes no difference to the installation process but
    # is useful for the log
    TOOL_IS_NEW="False"
    if [ $MODE == "install" ]; then
      TOOL_IS_NEW=$(python scripts/is_tool_new.py -g $PRODUCTION_URL -a $PRODUCTION_API_KEY -n $TOOL_NAME -o $OWNER)
    fi

    unset STAGING_TESTS_PASSED PRODUCTION_TESTS_PASSED; # ensure these values do not carry over from previous iterations of the loop

done
