#
# script to create the ArXiv submission
#
# please be sure that you run compile.sh in the main directory before running 
# this script, so paper-hierarchical.bbl and the GRAPHICS/*eps-converted-to.pdf files 
# are created
#

cd /users/srio/Documents/paper-TT-perfect-crystals
rm -rf ARXIV
rm ARXIV.zip
mkdir ARXIV
cd ARXIV

mkdir figures
cp ../figures/*.png figures
cp ../figures/*.pdf figures
cp ../main.tex .


cp ../iucr.bib .
cp ../iucr.bst .
cp ../iucr.cls .

rm main.pdf 

pdflatex main.tex
bibtex main
sleep 1.0
pdflatex main.tex
pdflatex main.tex

okular main.pdf

sleep 1.0
rm main.aux main.blg main.log main.pdf
cd ..
zip -r ARXIV.zip ARXIV
