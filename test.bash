#!/bin/bash
set -e
script_dir=$(dirname $0)
cd $script_dir

# temporary test output
mkdir -p test/tmp/

## old test
#bin/bibber  test/test.bib test/tmp/output.html-format.html --output html --latex2html --limit-fields 
#cmp test/test.html out.html
#echo diff $?

# # new test
# bin/bibber  test/test.bib test/tmp/output.htmlsectioned-format.html  --output htmlsectioned --latex2html --limit-fields 
# cmp test/output.htmlsectioned-format.html test/tmp/output.htmlsectioned-format.html
# echo diff $?

test_format() {
    format="$1" 
    bin/bibber  test/test.bib test/tmp/output.${format}-format.html  --output ${format} --latex2html --limit-fields 
    cmp test/output.${format}-format.html test/tmp/output.${format}-format.html
    echo diff $?
}

# old test
test_format html

# new test
#test_format htmlsectioned
