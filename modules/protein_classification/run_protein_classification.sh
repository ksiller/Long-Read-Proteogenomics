nextflow run protein_classification.nf \
--name test \
--sample_gtf input/jurkat_with_cds.chr22.gtf \
--best_orf input/jurkat_best_orf_chr22.tsv \
--reference_gtf input/gencode_chr22.gtf
