import sys
import csv
import json
import click
from collections import OrderedDict
from eth_utils import to_checksum_address, to_wei


class DuplicateAddress(Exception):
    def __str__(self):
        return 'Duplicate address found: {}'.format(self.args[0])


@click.command()
@click.argument('spec_file', type=click.File('rt'))
@click.argument('csv_file', type=click.File('rt'))
def main(spec_file, csv_file):
    spec = json.load(spec_file, object_pairs_hook=OrderedDict)
    seen = set(to_checksum_address(x) for x in spec['accounts'])
    reader = csv.reader(csv_file)
    for row in reader:
        address = to_checksum_address(row[0])  # will raise on invalid address
        balance_wei = to_wei(row[1], 'ether')  # will raise on invalid balance
        if address in seen:
            raise DuplicateAddress(address)
        seen.add(address)
        spec['accounts'][address] = {'balance': str(balance_wei)}
    with open('spec.new.json', 'wt') as f:
        f.write(json.dumps(spec, indent=2))
    click.echo('written to spec.new.json')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, DuplicateAddress) as e:
        click.secho(str(e), fg='red')
        sys.exit(1)
