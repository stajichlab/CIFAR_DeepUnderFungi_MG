#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 1 -c 96 --mem 24gb --out logs/download_sra.%a.log

module load sratoolkit
module load workspace/scratch

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
SRAFILE=samples.csv
FOLDER=input

MAX=$(wc -l $SRAFILE | awk '{print $1}')
if [ $N -gt $MAX ]; then
  echo "$N is too big, only $MAX lines in $SRAFILE"
  exit
fi
if [ ! -s $SRAFILE ]; then
	echo "No SRA file $SRAFILE"
	exit
fi
SRA=$(tail -n +2 $SRAFILE | sed -n ${N}p | cut -d, -f2)
if [ ! -s ${SRA}_1.fastq.gz ]; then
	fasterq-dump -O $FOLDER --split-3 -t $SCRATCH --threads $CPU $SRA
fi

