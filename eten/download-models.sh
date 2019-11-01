#!/bin/bash

for pair in eten enet; do
    wget -nc -P $pair.student.tiny11/ http://data.statmt.org/romang/bergamot/models/eten/$pair.student.tiny11/model.npz
    wget -nc -P $pair.student.tiny11/ http://data.statmt.org/romang/bergamot/models/eten/$pair.student.tiny11/lex.s2t
    wget -nc -P $pair.student.tiny11/ http://data.statmt.org/romang/bergamot/models/eten/vocab.eten.spm

    wget -nc -P $pair.teacher.bigx2/ http://data.statmt.org/romang/bergamot/models/eten/$pair.teacher.bigx2/model{1,2}.npz
    wget -nc -P $pair.teacher.bigx2/ http://data.statmt.org/romang/bergamot/models/eten/vocab.eten.spm
done