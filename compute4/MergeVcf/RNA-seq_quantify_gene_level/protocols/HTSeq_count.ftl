#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6

sortedBam="${sortedBam}"
htseq_count="${htseq_count}"
annotationGtf="${annotationGtf}"
txtExpression="${txtExpression}"
samtools=${samtools}
python=${python}

<#noparse>

echo -e "sortedBam=${sortedBam}\nannotationGtf=${annotationGtf}\ntxtExpression=${txtExpression}"

alloutputsexist ${txtExpression}

module load python/2.7.5

set -e
set -u

echo "Sorting bam file by name"

if ${samtools} \
	sort \
	-n \
	${sortedBam} \
	${TMPDIR}/nameSorted
then 
	echo "bam file sorted"
else
	echo "Failed to sort bam file"
	rm -f ${TMPDIR}/nameSorted.bam
	exit 1
fi 
	
echo -e "\nQuantifying expression"

if ${samtools} \
	view -h \
	${TMPDIR}/nameSorted.bam | \
	${python} \
	${htseq_count} \
	-m union \
	-s no \
	- \
	${annotationGtf} | \
	head -n -5 \
	> ${txtExpression}___tmp___;
then
	echo "Gene count succesfull"
	mv ${txtExpression}___tmp___ ${txtExpression}
else
	echo "Genecount failed"
	rm -f ${TMPDIR}/nameSorted.bam
	exit 1
fi

rm ${TMPDIR}/nameSorted.bam

echo "Finished!"
</#noparse>
