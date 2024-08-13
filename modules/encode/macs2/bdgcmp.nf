process MACS2_BDGCMP {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	cpus   = {1 * task.attempt}
	memory = {8.GB * 1}
	time   = {24.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bedtools_macs2_ucsc-bedgraphtobigwig:831ad901e42b7721"

	input:
	tuple val(meta) , path(treat_pileup), path(control_lambda), path(tagalign), val(scale_factor)
	tuple val(meta2), path(fai)

	output:
	tuple val(meta), path("*.fc.signal.bigwig")  , optional: false, emit: fc_bigwig
	tuple val(meta), path("*.pval.signal.bigwig"), optional: false, emit: pval_bigwig
	tuple val(task.process), val("macs2")   , eval("macs2 --version | head -n 1 | sed 's/macs2 //'")                , topic: versions
	tuple val(task.process), val("bedtools"), eval("bedtools --version | sed 's/bedtools v//'")                     , topic: versions
	tuple val(task.process), val("awk")     , eval("awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//'")                , topic: versions
	tuple val(task.process), val("bedGraphToBigWig"), eval("bedGraphToBigWig 2>&1 | head -n 1 | sed 's/bedGraphToBigWig v //;s/ -.*//'") , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	
	"""
	macs2 bdgcmp \\
		-t ${treat_pileup} \\
		-c ${control_lambda} \\
		--o-prefix ${prefix} \\
		-m FE
	
	cut -f1,2 ${fai} > genome.sizes

	# Make the FC signal bigwig
	bedtools slop -i ${prefix}_FE.bdg -g genome.sizes -b 0 \\
		| awk '{if (\$3 != -1) print \$0}' \\
		| sort -k1,1 -k2,2n \\
		| awk 'BEGIN{OFS="\\t"}{if (NR==1 || NR>1 && (prev_chr!=\$1 || prev_chr==\$1 && prev_chr_e<=\$2)) {print \$0}; prev_chr=\$1; prev_chr_e=\$3;}' \\
		> ${prefix}_FE.bedGraph
	
	bedGraphToBigWig ${prefix}_FE.bedGraph genome.sizes ${prefix}.fc.signal.bigwig
	rm -f ${prefix}_FE.bedGraph ${prefix}_FE.bdg

	# Make pval signal track
	
	echo "${scale_factor}"

	macs2 bdgcmp \\
		-t ${treat_pileup} \\
		-c ${control_lambda} \\
		--o-prefix ${prefix} \\
		-m ppois \\
		-S ${scale_factor}

	bedtools slop -i ${prefix}_ppois.bdg -g genome.sizes -b 0 \\
		| awk '{if (\$3 != -1) print \$0}' \\
		| sort -k1,1 -k2,2n \\
		| awk 'BEGIN{OFS="\\t"}{if (NR==1 || NR>1 && (prev_chr != \$1 || prev_chr==\$1 && prev_chr_e<=\$2)) {print \$0}; prev_chr=\$1; prev_chr_e=\$3;}' \\
		> ${prefix}_ppois.bedGraph
	
	bedGraphToBigWig ${prefix}_ppois.bedGraph genome.sizes ${prefix}.pval.signal.bigwig
	rm -f ${prefix}_ppois.bedGraph ${prefix}_ppois.bdg

	

	"""
}