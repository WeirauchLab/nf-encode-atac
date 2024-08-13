process LIB_QC {
	tag "${meta.id}"

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bedtools_samtools_coreutils_gawk:35ad44d2da724fcb"

	input:
	tuple val(meta), path(bam)

	output:
	tuple val(meta), path("*.lib_qc.tsv"), optional: true, emit: tsv

	// version strings
	tuple val(task.process), val("bedtools"), eval("bedtools --version | sed 's/bedtools v//'")            , topic: versions
	tuple val(task.process), val("awk")     , eval("awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//'")       , topic: versions
	tuple val(task.process), val("samtools"), eval("samtools --version | head -n 1 | sed 's/^samtools //'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	def chr_filter = task.ext.chr_filter ? "| grep -v '^${task.ext.chr_filter}\\s'" : ""
	if(meta.single_end){
		"""
		bedtools bamtobed -i ${bam} \\
			| awk 'BEGIN{OFS="\\t"}{print \$1,\$2,\$3,\$6}' \\
			${chr_filter} \\
			| sort \\
			| uniq -c \\
			| awk '
				BEGIN { mt=0; m0=0; m1=0; m2=0 }
				\$1 == 1 { m1++ }
				\$1 == 2 { m2++ }
				{ m0++; mt += \$1 }
				END {
					m1_m2 = (m2 > 0) ? m1/m2 : -1.0
					m0_mt = (mt > 0) ? m0/mt : 0
					m1_m0 = (m0 > 0) ? m1/m0 : 0
					printf "total_fragments\\tdistinct_fragments\\tpositions_with_one_read\\tpositions_with_two_reads\\tnrf\\tpbc1\\tpbc2\\n%d\\t%d\\t%d\\t%d\\t%.6f\\t%.6f\\t%.6f\\n", mt, m0, m1, m2, m0_mt, m1_m0, m1_m2
				}
				' \\
			> ${prefix}.lib_qc.tsv
		"""
	} else {
		"""
		samtools sort -n ${bam} \\
			| bedtools bamtobed -bedpe -i - \\
			| awk 'BEGIN{OFS="\\t"}{print \$1,\$2,\$4,\$6,\$9,\$10}' \\
			${chr_filter} \\
			| sort \\
			| uniq -c \\
			| awk '
				BEGIN { mt=0; m0=0; m1=0; m2=0 }
				\$1 == 1 { m1++ }
				\$1 == 2 { m2++ }
				{ m0++; mt += \$1 }
				END {
					m1_m2 = (m2 > 0) ? m1/m2 : -1.0
					m0_mt = (mt > 0) ? m0/mt : 0
					m1_m0 = (m0 > 0) ? m1/m0 : 0
					printf "total_fragments\\tdistinct_fragments\\tpositions_with_one_read\\tpositions_with_two_reads\\tnrf\\tpbc1\\tpbc2\\n%d\\t%d\\t%d\\t%d\\t%.6f\\t%.6f\\t%.6f\\n", mt, m0, m1, m2, m0_mt, m1_m0, m1_m2
				}
				' \\
			> ${prefix}.lib_qc.tsv
		"""
	}
}