# Train_LM_with_kaldilm
In this repository, I will show how to train LM files (xxx.arpa) with kaldilm. I suggest that you'd better run this script 
in Linux.

## How to run
Usage:
```
./train_lm.sh <train.text> <lexicon.txt> <lm-output-dir> <ngram>
```
First, this script assum that you have already got the following two files:

train.text:
```
train_sample_idx0  <word1> <word2> <word3> ... <wordN>
train_sample_idx1  <word1> <word2> <word3> ... <wordF>
train_sample_idx2  <word1> <word2> <word3> ... <wordG>
       .              .       .       .    ...    .
train_sample_idxM  <word1> <word2> <word3> ... <wordH>
```

lexicon.txt:
```
word1  <phone1> <phone2> <phone3> ... <phoneN>
word2  <phone1> <phone2> <phone3> ... <phoneF>
word3  <phone1> <phone2> <phone3> ... <phoneG>
  .       .        .        .     ...    .
wordM  <phone1> <phone2> <phone3> ... <phoneH>
```

Second, you should decide your LM output dir, such as `timit_data/lm`.

Last, you need just run the following command:
```
./train_lm.sh <xxx/train.text> <xxx/lexicon.txt> <xxx/lm>
```
or
```
bash train_lm.sh <xxx/train.text> <xxx/lexicon.txt> <xxx/lm>
```

## A TIMIT example
In this example, the each sample is a phone list and the phone is used to play the modeling unit. So the word is equal to the phone.
You can run the following command to get relative LM files:
```
./train_lm.sh timit_data/lang_phone/train.text timit_data/lang_phone/lexicon.txt timit_data/lm 4
```
