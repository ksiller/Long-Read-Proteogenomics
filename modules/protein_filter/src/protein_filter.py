#!/usr/bin/env python3

#%%
import pandas as pd
import numpy as np
from Bio import SeqIO
import argparse

PROTEIN_SPLICE_CATEGORIES_TO_KEEP = [
    'novel_in_catalog', 
    'full-splice_match', 
    'incomplete-splice_match', 
    'novel_not_in_catalog'
    ]
def filter_protein_database(db_info, database_sequence_file,protein_classification, name):
    poor_classifications = (
        protein_classification
            .query(f'pr_splice_cat not in {PROTEIN_SPLICE_CATEGORIES_TO_KEEP} | protein_classification.str.contains("trunc")')
    )
    pb_acc_to_drop = list(poor_classifications['pb'])
    db_info = db_info.query(f'base_acc not in {pb_acc_to_drop}')
    db_info.to_csv(f'{name}.filtered_protein_database.tsv', sep='\t',index=False)

    input_seq_iterator = SeqIO.parse(database_sequence_file, "fasta")
    filtered_seq_iterator = (record for record in input_seq_iterator if record.id.split('|')[1] not in pb_acc_to_drop)
    SeqIO.write(filtered_seq_iterator, f"{name}.filtered_protein_database.fasta", "fasta")

def main():
    parser = argparse.ArgumentParser(description='Proccess ORF related file locations')
    parser.add_argument('--name', action='store', dest= 'name',help='samplel name')
    parser.add_argument('--protein_classification', action='store', dest= 'protein_classification',help='samplel name')
    parser.add_argument('--protein_database_info', action='store', dest= 'protein_database_info',help='samplel name')
    parser.add_argument('--protein_database_sequences', action='store', dest= 'protein_database_sequences',help='samplel name')
    args = parser.parse_args()

    db_info = pd.read_table(args.protein_database_info)
    protein_classificaiton = pd.read_table(protein_classification)
    filter_protein_database(db_info, args.protein_database_sequences, protein_classification, args.name)
#%%
if __name__ == "__main__":
    main()

# %%
