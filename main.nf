// Channel
//     .value(file(params.toml))
//     .ifEmpty { error "Cannot find toml file for parameter --toml: ${params.toml}" }
//     .set { ch_toml } 

// Channel
//     .value(file(params.orf_calls))
//     .ifEmpty { error "Cannot find gtf file for parameter --gencode_gtf: ${params.orf_calls}" }
//     .set { ch_orf_calls } 


// TODO - is orf_fasta the refined database? If so, can we call this parameter --refined_protein_db or somethign like that?
// TODO cont. - orf typically means the nt sequence underlying the protein

Channel
    .value(file(params.orf_fasta))
    .ifEmpty { error "Cannot find gtf file for parameter --orf_fasta: ${params.orf_fasta}" }
    .set { ch_orf_fasta }


if (!params.orf_meta) exit 1, "Cannot find file for parameter --orf_meta: ${params.orf_meta}"
ch_orf_meta = Channel.value(file(params.orf_meta))

if (!params.rr_toml) exit 1, "Cannot find file for parameter --rr_toml: ${params.rr_toml}"
ch_rr_toml = Channel.value(file(params.rr_toml))



Channel
    .fromPath("${params.mass_spec}/*.raw")
    .set{ch_mass_spec_raw}

Channel
    .fromPath("${params.mass_spec}/*.{mzml,mzML}")
    .set{ch_mass_spec_mzml}



process mass_spec_raw_convert{
    publishDir "${params.outdir}/raw_convert/", mode: 'copy'

    input:
        file(raw_file) from ch_mass_spec_raw

    output:
        file("*") into ch_mass_spec_converted

    script:
        """
        wine msconvert $raw_file --filter "peakPicking true 1-"
        """
}

// TODO - can you explain to me why this was needed?
ch_mass_spec_combined = ch_mass_spec_mzml.concat(ch_mass_spec_converted)

process metamorpheus_with_sample_specific_database_rescue_resolve{
    tag " $mass_spec"
    publishDir "${params.outdir}/metamorpheus/rescue_resolve", mode: 'copy'

    input:
        // file(orf_calls) from ch_orf_calls
        file(orf_fasta) from ch_orf_fasta
        // file(toml) from ch_toml
        file(mass_spec) from ch_mass_spec_combined.collect()
        file(toml) from ch_rr_toml
        file(orf_meta) from ch_orf_meta

    output:
        file("toml/*")
        file("search_results/Task1SearchTask/All*")
        file("search_results/Task1SearchTask/prose.txt")
        file("search_results/Task1SearchTask/results.txt")
        file("search_results/Task1SearchTask/AllPeptides.${params.name}.rescue_resolve.psmtsv")
        file("search_results/Task1SearchTask/AllQuantifiedProteinGroups.${params.name}.rescue_resolve.tsv")
    
    script:
        """
        dotnet /metamorpheus/CMD.dll -g -o ./toml --mmsettings settings 
        dotnet /metamorpheus/CMD.dll -d $orf_fasta -s $mass_spec -t $toml -v normal --mmsettings settings -o ./search_results --orf $orf_meta --cpm 25

        mv search_results/Task1SearchTask/AllPeptides.psmtsv search_results/Task1SearchTask/AllPeptides.${params.name}.rescue_resolve.psmtsv
        mv search_results/Task1SearchTask/AllQuantifiedProteinGroups.tsv search_results/Task1SearchTask/AllQuantifiedProteinGroups.${params.name}.rescue_resolve.tsv
        """
}