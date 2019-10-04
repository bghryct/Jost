#!/bin/sh


# -------------------------------------------------------------------
# Update the following as needed ------------------------------------
set -e


echo "Generating VFs"
# mkdir -p ./fonts/variable
fontmake -m source/jost.designspace -o variable --round-instances -a --output-path source/vf/jost\[ital,wght\].ttf

echo "Removing Build UFOS"

rm -rf master_ufo/ instance_ufo/

echo "Build UFOS Removed"

echo "Post processing"

ttfs=$(ls fonts/static/*.ttf)
echo $ttfs
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	gftools fix-nonhinting $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done
echo "fixed nonhinting ttfs as well as DSIG"

rm ./fonts/static/*backup*.ttf

vfs=$(ls ./fonts/variable/*.ttf)
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	gftools fix-nonhinting $vf "$vf.fix";
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=./fonts/variable/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm ./fonts/variable/*.ttx
done
rm ./fonts/variable/*backup*.ttf

echo "fix vf meta? ok let's try that. I'm trying to fix VF meta"
gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv "$vf.fix" $vf;
done

echo "Post processing complete"
