#!/usr/bin/env bash

# The script downloads and installs kaldi_lm

GIT=${GIT:-git}

set -e

#echo "Installing kaldi_lm"

if [ ! -d "kaldi_lm" ]; then
  $GIT clone https://github.com/danpovey/kaldi_lm.git || exit 1
fi

cd kaldi_lm
make || exit 1;
cd ..

(
  set +u

  wd=`pwd`
  echo "export PATH=\$PATH:$wd/kaldi_lm"
) >> env.sh

echo >&2 "Installation of kaldi_lm finished successfully"
