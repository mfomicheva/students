#!/bin/bash

MARIAN=/home/nbogoych/marian-dev/build_VSCODE

SRC=en
TRG=de

mkdir -p speed

~/.local/bin/sacrebleu -t wmt19 -l $SRC-$TRG --echo src > speed/newstest2019.$SRC

if [ ! -f model.intgemm.alphas.bin ]; then

test -e model.alphas.npz || $MARIAN/marian-decoder $@ \
    --relative-paths -m model.npz -v vocab.$TRG$SRC.spm vocab.$TRG$SRC.spm \
    -i speed/newstest2019.$SRC -o speed/cpu.newstest2019.$TRG \
    --beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
    --skip-cost --shortlist lex.s2t.gz 50 50 --cpu-threads 1 \
    --quiet --quiet-translation --log speed/cpu.newstest2019.log --optimize8 --intgemm-shifted --intgemm-shifted-all --dump-quantmult  2> quantmults

test -e model.alphas.npz || $MARIAN/../scripts/alphas/extract_stats.py quantmults model.npz model.alphas.npz

test -e model.intgemm.alphas.bin || $MARIAN/marian-conv -f model.alphas.npz -t model.intgemm.alphas.bin --gemm-type intgemm8

fi
echo "### Translating wmt19 $SRC-$TRG on CPU"
$MARIAN/marian-decoder $@ \
    --relative-paths -m model.intgemm.alphas.bin -v vocab.$TRG$SRC.spm vocab.$TRG$SRC.spm \
    -i speed/newstest2019.$SRC -o speed/cpu.newstest2019.$TRG \
    --beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
    --skip-cost --shortlist lex.s2t.gz 50 50 --cpu-threads 1 \
    --quiet --quiet-translation --log speed/cpu.newstest2019.log --optimize8 --intgemm-shifted --intgemm-shifted-all --use-precomputed-alphas

tail -n1 speed/cpu.newstest2019.log
~/.local/bin/sacrebleu -t wmt19 -l $SRC-$TRG < speed/cpu.newstest2019.$TRG | tee speed/cpu.newstest2019.$TRG.bleu
