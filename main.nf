#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// ---------------------- INPUTS ----------------------
Channel
    .fromPath("${params.base_dir}/**/*_all_contig.fasta")
    .map { fasta ->
        def basename   = fasta.getBaseName().replace("_all_contig", "")  // Sanofi_CTVpos_0282
        def sample     = basename.replaceAll(/_\d+$/, "")                // Sanofi_CTVpos
        def patient    = fasta.getParent().getName()                      // 0282
        def annotation = fasta.getParent().resolve("${basename}_all_contig_annotations.csv")
        tuple(fasta, basename, sample, patient, annotation)
    }
    .set { samples }

// ---------------------- PROCESS 1 ----------------------
process assign_genes {
    tag "${sample}"
    publishDir "${params.outdir}/${patient}", mode: 'copy', saveAs: { filename ->
        filename.endsWith(".fmt7") ? filename : null
    }

    input:
    tuple path(fasta), val(basename), val(sample), val(patient), path(annotation)

    output:
    tuple path("${basename}_igblast.fmt7"), val(basename), val(sample), val(patient), path(fasta), path(annotation)

    script:
    """
    AssignGenes.py igblast \
        -s ${fasta} \
        -b ${params.igblast_dir} \
        --organism human \
        --loci ig \
        --format blast

    mv ${basename}_all_contig_igblast.fmt7 ${basename}_igblast.fmt7
    """
}

// ---------------------- PROCESS 2 ----------------------
process make_db {
    tag "${sample}"

    input:
    tuple path(igblast), val(basename), val(sample), val(patient), path(fasta), path(annotation)

    output:
    tuple path("${basename}_db-pass.tsv"), val(sample), val(patient)

    script:
    """
    MakeDb.py igblast \
        -i ${igblast} \
        -s ${fasta} \
        -r ${params.germline_dir} \
        --10x ${annotation} \
        --extended

    cp ${basename}_igblast_db-pass.tsv ${basename}_db-pass.tsv
    """
}


// ---------------------- PROCESS 3 ----------------------
process add_metadata {
    tag "${sample}"
    publishDir "${params.outdir}/${patient}", mode: 'copy'

    input:
    tuple path(dbfile), val(sample), val(patient)

    output:
    path("${sample}_db-pass.tagged.tsv")

    script:
    """
    awk -v pat="${patient}" -v sid="${sample}" '
        BEGIN{FS=OFS="\\t"}
        NR==1{print \$0, "patient", "sample_id"; next}
        {print \$0, pat, sid}
    ' ${dbfile} > ${sample}_db-pass.tagged.tsv
    """
}

// ---------------------- WORKFLOW ----------------------
workflow {
    samples
        | assign_genes
        | make_db
        | add_metadata
}