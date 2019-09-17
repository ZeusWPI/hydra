#!usr/bin/env python
#
# Converts transaction data to crowded data.
#
# These scripts are based on work done by Pieter De Clercq and Alexander Van Dyck for the course Datavisualisation.
#
# A more detailed description of how this all works is provided in the file "predictions.md".
#
import random
from intervaltree import IntervalTree
from datetime import timedelta, datetime
from enum import Enum
from typing import Optional, NamedTuple, List, Set, Tuple
from datetimerange import DateTimeRange

import glob
import logging
import pandas as pd
import numpy as np
import datetime as dt

logging.basicConfig()
# Log all info messages.
logging.root.setLevel(logging.INFO)

# Maps each resto onto a list of files; these will be read.
RESTO_PATTERNS = {
    'sterre': ['Campus Sterre'],
    'heymans': ['Campus Heymans'],
    'brug': ['Brug middag', 'Brug avond'],
    'merelbeke': ['Campus Merelbeke'],
    'dunant': ['Campus Dunant'],
    'coupure': ['Campus Coupure'],
    'jansvest': ['Sint Jansvest'],
    'kantienberg': ['Kantienberg']
}


class Type(NamedTuple):
    duration: timedelta  # How long the person stays in the resto after purchasing it
    takeaway: bool  # If the item can be consumed outside the resto


# Defines the types of the items of the transactions
class Types(Enum):
    SANDWICH = Type(timedelta(minutes=10), True)
    SOUP = Type(timedelta(minutes=13), True)
    MAIN = Type(timedelta(minutes=27), False)
    DESSERT = Type(timedelta(minutes=4), False)
    DRINKS = Type(timedelta(minutes=1), True)
    FRUIT = Type(timedelta(minutes=2), True)
    VEGETABLE = Type(timedelta(minutes=15), False)

    @property
    def duration(self) -> timedelta:
        return self.value.duration

    @property
    def is_takeaway(self) -> bool:
        return self.value.takeaway


# How likely someone is to actually consume the takeaway somewhere else
TAKEAWAY_FACTOR = 0.84

BASE_TIME = timedelta(minutes=20)

# We sample for frequency every X minutes.
CROWD_SAMPLE_FREQUENCY = timedelta(minutes=10)

# Friendly types, meaning if both of these types are in one transaction, we only count one.
# Read as: if type [key] is present, types [value] should not be counted.
ABSORBS = {
    Types.SANDWICH: {Types.DRINKS},
    Types.SOUP: {Types.SANDWICH, Types.DRINKS},
    Types.MAIN: {Types.VEGETABLE, Types.DRINKS},
    Types.DESSERT: {Types.DRINKS},
    Types.FRUIT: {Types.DRINKS},
    Types.VEGETABLE: {Types.DRINKS},
    Types.DRINKS: set()
}


class Transaction(NamedTuple):
    """Represents a transaction by a single person (on a best effort basis)"""
    timestamp: datetime
    items: List[Types]


def read_files(resto: str, data_folder: str, output_folder: Optional[str]) -> pd.DataFrame:
    """
    Read all data for a resto in a certain folder. This function will filter the data, so that only useful data
    remains in the output.
    :param output_folder: Folder to write output to. If None, no output will be written.
    :param resto: For which resto data should be read.
    :param data_folder: The folder containing the data files.
    :return: A dataframe containing the (raw) data.
    """
    # Patterns for the resto
    patterns = [f"{data_folder}/{name}-*.csv" for name in RESTO_PATTERNS[resto]]
    # Files for the resto
    nested_files = [glob.glob(pattern) for pattern in patterns]
    files = [file for file_list in nested_files for file in file_list]
    logging.info(f'Found data files: {files}')
    # Dataframes for each file
    frames = [pd.read_csv(file) for file in files]
    # All data
    data: pd.DataFrame = pd.concat(frames)
    logging.info(f'Found a total of {len(data)} raw transactions')

    # Drop the resto column; we know it.
    data.drop(columns='Filiaal', inplace=True)
    logging.debug('Dropped "Filiaal" column')
    # Rename columns to more sensible names
    data.rename(inplace=True, columns={
        'Datum': 'date',
        'Tijdstip': 'time',
        'ArtikelOmschrijving': 'description',
        'ArtikelAantalEenheden': 'amount'
    })
    logging.debug('Renamed columns')
    # Convert the date/time columns
    data['timestamp'] = pd.to_datetime(data['date'] + 'T' + data['time'])
    data.drop(columns=['date', 'time'], inplace=True)
    logging.debug('Combined "date" and "time" columns')

    # Remove all empty rows, summation rows
    data.dropna(inplace=True)
    logging.debug('Dropped empty rows')

    # Drop rows where the count is less than 1
    data = data[data.amount >= 1]
    data.drop(columns='amount', inplace=True)
    logging.debug('Dropped negative rows and "amount" column')

    # Sort by date
    data.sort_values(by='timestamp', inplace=True)
    logging.debug('Sorted output')

    logging.info(f'After processing, {len(data)} transactions remain')

    if output_folder:
        output_file = f'{output_folder}/{resto}.csv'
        logging.info(f'Writing processed transactions to {output_file}')
        # Use CRLF to conform to RFC4180
        data.to_csv(output_file, index=False, line_terminator='\r\n', date_format='%Y-%m-%dT%H:%M:%S')

    r = data.groupby(['timestamp']).groups
    print(r)

    return data


def calculate_duration(transaction: Transaction) -> timedelta:
    """
    Calculates a duration for a transaction. This duration indicates an estimate of how long the customer will stay in
    the resto after the transaction. This allows us to estimate how many people are in the resto at any given time.
    :param transaction: The transaction.
    """
    # Check if this is a takeaway meal.
    if all(x.is_takeaway for x in transaction.items) and random.random() < TAKEAWAY_FACTOR:
        logging.debug(f'Transaction is a take-away')
        return timedelta()
    # First eliminate duplicates.
    types: Set[Types] = set(transaction.items)
    # Sort the types by their duration.
    sorted_types = sorted(types, key=lambda item: item.duration, reverse=True)
    logging.debug(f'Sorted types are {sorted_types}')
    # Remove the ones we don't want to count twice.
    resulting_types = []
    to_remove = []
    for potential_type in sorted_types:
        if potential_type not in to_remove:
            resulting_types.append(potential_type)
            resulting_types.extend(ABSORBS[potential_type])
    logging.debug(f'After clean-up, remaining types are {resulting_types}')

    return sum((t.duration for t in resulting_types), timedelta(0))


def calculate_times(transactions: List[Transaction], output_file: Optional[str]) -> pd.DataFrame:
    """
    Calculate an interval tree for the list of transactions.
    :param output_file: The output file for the transactions. If None, it will not be saved.
    :param transactions: The transactions to process.
    """
    pairs = [(x.timestamp, calculate_duration(x)) for x in transactions]
    data = pd.DataFrame(data=pairs, columns=['timestamp', 'duration'])

    # The division will give use the total amount of minutes.
    data['duration'] = data['duration'].apply(lambda delta: delta / timedelta(minutes=1))
    # Filter lengths of zero.
    data = data[(data != 0.0).all(1)]

    if output_file:
        logging.info(f'Writing processed transactions to {output_file}')
        # Use CRLF to conform to RFC4180
        data.to_csv(output_file, index=False, line_terminator='\r\n', date_format='%Y-%m-%dT%H:%M:%S')

    return data


def build_interval_tree(durations: pd.DataFrame) -> IntervalTree:
    """
    Constructs an interval tree for the given durations.
    """
    tree = IntervalTree()
    for row in durations.itertuples():
        start = row.timestamp.to_pydatetime() if isinstance(row.timestamp, pd.Timestamp) else row.timestamp
        delta = row.duration
        end = start + timedelta(minutes=delta)
        tree.addi(start, end)
    return tree


def calculate_crowds(durations: pd.DataFrame, times: List[List[str]], output_file: Optional[str]) -> pd.DataFrame:
    """
    Converts a list of transaction times to a list of crowds.
    :param durations: Each transaction with the accompanied duration.
    :param times: The time range we want to query.
    :param output_file: Optional output file, if None, nothing will be written.
    :return: The absolute crowd at CROWD_SAMPLE_FREQUENCY frequency.
    """
    # We need to generate the ranges we want.
    dates = sorted({x.to_pydatetime().date() if isinstance(x, pd.Timestamp) else x.date() for x in durations['timestamp'].tolist()})
    samples = []
    # For each day, we query in the opening hours.
    for date in dates:
        for opening in times:
            start, end = opening
            start_stamp = datetime.combine(date, dt.time.fromisoformat(start))
            end_stamp = datetime.combine(date, dt.time.fromisoformat(end))
            period = DateTimeRange(start_stamp, end_stamp)
            samples.extend(period.range(CROWD_SAMPLE_FREQUENCY))

    interval_tree = build_interval_tree(durations)

    data = [(time, len(interval_tree.at(time))) for time in samples]
    crowd_data = pd.DataFrame(data, columns=['timestamp', 'crowd'])

    if output_file:
        logging.info(f'Writing processed transactions to {output_file}')
        # Use CRLF to conform to RFC4180
        crowd_data.to_csv(output_file, index=False, line_terminator='\r\n', date_format='%Y-%m-%dT%H:%M:%S')

    return crowd_data
