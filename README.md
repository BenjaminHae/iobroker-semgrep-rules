# Semgrep rules for iobroker.javascript

The script in this repository generates a markdown file that contains an overview of objects and schedules used in scripts used for iobroker.javascript.

For example, when a script contains the following code

```
```

this result is generated by the script:

```
```

## Installation

Requirements are python3 and semgrep:

```
pip install -r requirements.txt
```

## Usage

```
./generateDocs.sh path/to/scripts_directory out_file.md
```

## Known Problems

The semgrep rules work best with plain string constants, string constants within arrays or format-strings (enclosed in backticks `\``) are often not identified correctly.

