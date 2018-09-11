import argparse


def parse_output(description='Run script that produces API output') -> str:
    """
    Parse the output directory from the arguments.
    :return: The output directory.
    """
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('output', type=str, required=True, help='the output directory for the data')
    options = parser.parse_args()
    return options.output