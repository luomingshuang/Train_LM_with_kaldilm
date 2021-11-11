#!/usr/bin/env bash

# To be run from one directory above this script.
. ./install_kaldi_lm.sh
. ./path.sh

if [ $# -ne 4 ]; then
  echo "Usage: ./train_lm.sh <train.text> <lexicon.txt> <lm-output-dir> <ngram>"
  echo "e.g.: ./train_lm.sh timit_data/lang_phone/train.text timit_data/lang_phone/lexicon.txt timit_data/lm"
  echo "<train.text> is the training corpus"
  echo "<lexicon.txt> is the lexicon file"
  echo "<lm-output-dir> is the output directory for LM files"
  echo "<ngram> is a number, such as 2, 3, 4 and so on."
fi

text=$1
lexicon=$2
lmdir=$3
ngram=$4

mkdir -p $lmdir 

for f in "$text" "$lexicon"; do
  [ ! -f $x ] && echo "$0: No such file $f" && exit 1
done

# This script assumes you have already got
#
#  train.text:
#
#     train_sample_idx0  <word1> <word2> <word3> ... <wordN>
#     train_sample_idx1  <word1> <word2> <word3> ... <wordF>
#     train_sample_idx2  <word1> <word2> <word3> ... <wordG>
#            .              .       .       .    ...    .
#     train_sample_idxM  <word1> <word2> <word3> ... <wordH>
#
#  lexicon.txt:
#
#     word1  <phone1> <phone2> <phone3> ... <phoneN>
#     word2  <phone1> <phone2> <phone3> ... <phoneF>
#     word3  <phone1> <phone2> <phone3> ... <phoneG>
#       .       .        .        .     ...    .
#     wordM  <phone1> <phone2> <phone3> ... <phoneH>


kaldi_lm=$(which train_lm.sh)
if [ -z $kaldi_lm ]; then
  echo "$0: train_lm.sh is not found. That might mean it's not installed"
  echo "$0: or it is not added to PATH"
  echo "$0: Please use the following commands to install it"
  echo "  git clone https://github.com/danpovey/kaldi_lm.git"
  echo "  cd kaldi_lm"
  echo "  make -j"
  echo "Then add the path of kaldi_lm to PATH and rerun $0"
  exit 1
fi

cleantext=$lmdir/text.no_oov

cat $text | awk -v lex=$lexicon 'BEGIN{while((getline<lex) >0){ seen[$1]=1; } }
  {for(n=1; n<=NF;n++) {  if (seen[$n]) { printf("%s ", $n); } else {printf("<UNK> ");} } printf("\n");}' \
  >$cleantext || exit 1

cat $cleantext | awk '{for(n=2;n<=NF;n++) print $n; }' | sort | uniq -c |
  sort -nr >$lmdir/word.counts || exit 1

# Get counts from acoustic training transcripts, and add  one-count
# for each word in the lexicon (but not silence, we don't want it
# in the LM-- we'll add it optionally later).
cat $cleantext | awk '{for(n=2;n<=NF;n++) print $n; }' |
	cat - <(grep -w -v '!SIL' $lexicon | awk '{print $1}') |
  sort | uniq -c | sort -nr >$lmdir/unigram.counts || exit 1

# note: we probably won't really make use of <UNK> as there aren't any OOVs
cat $lmdir/unigram.counts | awk '{print $2}' | get_word_map.pl "<s>" "</s>" "<UNK>" >$lmdir/word_map ||
  exit 1

# note: ignore 1st field of train.txt, it's the utterance-id.
cat $cleantext | awk -v wmap=$lmdir/word_map 'BEGIN{while((getline<wmap)>0)map[$1]=$2;}
  { for(n=2;n<=NF;n++) { printf map[$n]; if(n<NF){ printf " "; } else { print ""; }}}' | gzip -c >$lmdir/train.gz ||
  exit 1

train_lm.sh --arpa --lmtype $ngram"gram-mincount" $lmdir || exit 1

# LM is small enough that we don't need to prune it (only about 0.7M N-grams).
# Perplexity over 128254.000000 words is 90.446690

# note: output is
# timit_data/lm/3gram-mincount/lm_unpruned.gz

echo "Finish the LM training."

exit 0
