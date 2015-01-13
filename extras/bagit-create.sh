# Run this script INSIDE of the directory that you want to bag (your "bag directory").
# There must be a "data" directory inside of the "bag directory".  This "data" directory holds all of the content that you want to bag.

echo "Bag the content in `pwd` ? [yes]:"
echo "(Typing anything other than 'yes' will exit.)"
echo -ne "> "

read input_variable
if [[ "$input_variable" != "yes" ]]; then
    echo "The BagIt process has been canceled."
    exit 0
fi

echo ""

# Check for 'data' directory.  This is required.
if [[ ! -d "data" ]]; then
    echo "Error: Could not find 'data' directory directly under `pwd`.  This directory is required, and is where your main bag content must be located."
    exit 1
fi

echo "Counting number of files in 'data' directory (and following symlinks)..."
TOTAL_NUMBER_OF_FILES=`find -L data | wc -l`
echo "Total: $TOTAL_NUMBER_OF_FILES"
#TODO: Eventually, it would be nice to use this number to show a checksum progress indicator (i.e. How many checksums have been calculated so far and how many are left?  Percentage?) 

START_TIME=`date`
START_UNIX_TIMESTAMP_IN_SECONDS="$(date +%s)"
echo "Starting BagIt process..."
echo "Start Data/Time: $START_TIME"
echo ""

echo "Calculating checksums for files in `pwd`/data..."
perform_step=0
if [[ -e "manifest-sha1.txt" ]]; then
    echo ""
    echo "There is already a manifest-sha1.txt file present. Do you want to regenerate it? [yes]:"
    echo "(Typing anything other than 'yes' will skip new checksum generation and will use the existing manifest-sha1.txt file for upcoming bag creation steps.)"
    echo -ne "> "
    read input_variable
    if [[ "$input_variable" == "yes" ]]; then
	perform_step=1
	echo "Recalculating checksums for files in `pwd`/data..."
    fi
else
    perform_step=1
fi
if [[ $perform_step -eq 1 ]]; then
    #payload-manifest.sh
    find data -type f -follow | while read f; do sha1sum "$f"; done > manifest-sha1.txt
fi

echo "Calculating Payload-Oxum: The 'octetstream sum' of the payload in `pwd`/data..."


#perform_step=0
#if [[ -e "oxum.txt" ]]; then
#    echo ""
#    echo "There is already an oxum.txt file present. Do you want to regenerate it? [yes]:"
#    echo "(Typing anything other than 'yes' will skip new oxum generation and will use the existing oxum.txt file for upcoming bag creation steps.)"
#    echo -ne "> "
#    read input_variable
#    if [[ "$input_variable" == "yes" ]]; then
#	perform_step=1
#	echo "Recalculating Payload-Oxum for files in `pwd`/data..."
#    fi
#else
#    perform_step=1
#fi
#if [[ $perform_step -eq 1 ]]; then
#    #oxum-space-safe.sh
#    find data -type f -follow -exec wc -lc "{}" > oxum.txt \;
#fi

TOTAL_OXUM_BYTE_SUM=0
SAVEIFS=$IFS # Save original, default $IFS file separator value
IFS=$(echo -en "\n\b") # Temporarily set file separator value to something that wouldn't show up in our files
files=$(find data -type f -follow)
for f in $files
do
  BYTE_SIZE=$(wc -c < "$f")
  TOTAL_OXUM_BYTE_SUM=$(($TOTAL_OXUM_BYTE_SUM + $BYTE_SIZE))
done
# restore $IFS default file separator
IFS=$SAVEIFS

echo "Total Oxum byte sum: $TOTAL_OXUM_BYTE_SUM"

# Now that we have the TOTAL_OXUM_BYTE_SUM, we can create bag-info.txt
BAGGING_DATE=`date +%Y-%m-%d`
echo "Bagging-Date: $BAGGING_DATE" > bag-info.txt
echo "Payload-Oxum: $TOTAL_OXUM_BYTE_SUM.$TOTAL_NUMBER_OF_FILES" >> bag-info.txt

# Create bagit.txt file, based on the spec and encoding that we're using
echo 'BagIt-version: 0.97' > bagit.txt
echo 'Tag-File-Character-Encoding: UTF-8' >> bagit.txt

# Create tagmanifest-sha1.txt.  LAST STEP. Contains hashes of all non-data-directory files in the bag.
echo "Generating tag manifest..."

# Remove existing tagmanifest-sha1.txt if present
if [[ -e "tagmanifest-sha1.txt" ]]; then
    rm tagmanifest-sha1.txt
fi

# Calculate and write out new tagmanifest-sha1.txt
touch tagmanifest-sha1.txt.tmp # We're using .tmp at the end so that this file isn't included in the checksum generation
TAG_MANIFEST_LINES=$(find . -maxdepth 1 -name "*.txt" | while read f; do sha1sum "$f" >> tagmanifest-sha1.txt.tmp; done)
mv tagmanifest-sha1.txt.tmp tagmanifest-sha1.txt

TOTAL_TIME_IN_SECONDS="$(($(date +%s)-START_UNIX_TIMESTAMP_IN_SECONDS))"

echo "BagIt process complete!"
echo "Total script execution time: $TOTAL_TIME_IN_SECONDS seconds"
echo "Enjoy your bag!"