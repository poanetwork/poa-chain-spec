# inject balances

a script to inject balances from csv to `spec.json`

## installation

requires python 3.6

```
pip install click ethereum-utils
```

## usage

```
python inject_balances.py spec.json balances.csv
```

the output will be written to `spec.new.json`
