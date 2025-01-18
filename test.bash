#!/bin/bash
set -e
script_dir=$(dirname $0)
cd $script_dir

# cleanup old tests
\rm -rf test/tmp/

# temporary test output
mkdir -p test/tmp/

test_format() {
    format="$1" 
    bin/bibber  test/test.bib test/tmp/output.${format}-format.html  --output ${format} --latex2html --limit-fields 
    cmp test/output.${format}-format.html test/tmp/output.${format}-format.html
    echo diff $?
}

# old test
#test_format html

# new test
test_format htmlsectioned
