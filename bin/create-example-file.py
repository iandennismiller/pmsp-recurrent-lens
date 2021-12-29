#!/usr/bin/env python3

import os

import sys
sys.path.insert(0, os.path.expanduser('~/Work/word-learning-jspsych/src/warping_dilution_study'))
sys.path.insert(1, os.path.expanduser('~/Work/pmsp-torch/src'))

import configparser
from jsfsdb import jsfsdb
import click
import pandas as pd

from warping_dilution_study.models.study import Study
from warping_dilution_study.models.partition import PartitionMap
from warping_dilution_study.models.stimuli import StimulusDatabase

from pmsp.english.frequencies import Frequencies
from pmsp.english.graphemes import Graphemes
from pmsp.english.phonemes import Phonemes


stimulus_csv_path = os.path.expanduser("~/Work/word-learning-jspsych/usr/stimulus-database/warping-dilution-full.csv")
frequency_filename = os.path.expanduser("~/Work/pmsp-torch/src/pmsp/data/word-frequencies.csv")

config_filename = os.environ["SETTINGS"]

cfg = configparser.ConfigParser()
cfg.read(config_filename)

db = jsfsdb(dbpath=cfg['DEFAULT']['dbpath'])

graphemes = Graphemes()
phonemes = Phonemes()

def generate(partition_map_id, partition_map_list, dilution, frequency):

    count = 0

    study = Study(
        dbpath=cfg['DEFAULT']['dbpath'],
        spreadsheet=stimulus_csv_path,
    )

    partition_map = PartitionMap(
        study=study,
        partition_map_id=partition_map_id,
    )

    for partition_map_idx in partition_map_list:
        for anchor in partition_map.get_partitions()[partition_map_idx].anchors:
            # print(anchor)

            type_str = "ANC_REG"
            if anchor.type == "exception":
                type_str = "ANC_EXC"
            elif anchor.type == "ambiguous":
                type_str = "ANC_AMB"

            print(f"name: {{{count}_{anchor.orthography}_{anchor.phonology.replace('/', '')}_{type_str}}}")

            # print(anchor.orthography)
            print(f"freq: {frequency / dilution:0.8f}")

            # print(graphemes.get_graphemes(anchor.orthography))
            orthography_vector = graphemes.get_graphemes(anchor.orthography)
            print(f"I: {' '.join([str(x) for x in orthography_vector])}")

            # print(anchor.phonology)
            phonology_vector = phonemes.get_phonemes(anchor.phonology)
            print(f"T: {' '.join([str(x) for x in phonology_vector])};")
            print()

            count += 1


def generate_probes(frequency):

    count = 0

    df = pd.read_csv('usr/data/probes_2021-07-29.csv')

    for idx, row in df.iterrows():

        print(f"name: {{{count}_{row.orth}_{row.phon.replace('/', '')}_{row.type}}}")

        print(f"freq: {frequency:0.8f}")

        orthography_vector = graphemes.get_graphemes(row.orth)
        print(f"I: {' '.join([str(x) for x in orthography_vector])}")

        phonology_vector = phonemes.get_phonemes(row.phon)
        print(f"T: {' '.join([str(x) for x in phonology_vector])};")
        print()

        count += 1


@click.group()
def cli():
    pass


@click.command('create_examples', short_help='Create example file.')
@click.option('--dilution', required=True, help='Dilution level.')
@click.option('--partition', required=True, help='Partition.')
@click.option('--frequency', required=True, help='Anchor frequency.')
def create_examples(dilution, partition, frequency):
    generate(
        partition_map_id=int(partition),
        partition_map_list=range(0, int(dilution)),
        dilution=int(dilution),
        frequency=float(frequency),
    )


@click.command('create_probes', short_help='Create probes example file.')
@click.option('--frequency', required=True, help='Probe frequency.')
def create_probes(frequency):
    generate_probes(
        frequency=float(frequency),
    )


cli.add_command(create_examples)
cli.add_command(create_probes)


if __name__ == '__main__':
    cli()
