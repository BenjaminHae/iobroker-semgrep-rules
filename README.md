# Semgrep rules for iobroker.javascript

The script in this repository generates a markdown file that contains an overview of objects and schedules used in scripts used for iobroker.javascript. The underlying technology to achieve this is [semgrep](https://semgrep.dev/).

For example, when a script contains the following code

```
id_of_thing1 = "this.is.id.1"
id_of_thing2 = "this.is.id.2"
variable = 3
id_of_thing3 = `this.is.id.${variable}`
id_of_thing4 = "this.is.id.4"
id_of_thing5 = "this.is.id.5"
id_of_thing6 = "this.is.id.6"


function bla() {
    getState(id_of_thing2)
    setState(id_of_thing1,true)
}
getStateAsync(id_of_thing3)
on(id_of_thing4, bla)
on({"id": id_of_thing5}, 
    ()=>{
        setState(id_of_thing3, false)
        setState(id_of_thing2, false)
    })
on({id: [id_of_thing6]}, bla)
)
schedule("19 5 * * *", bla)
```

this result is generated by the script:

```
## test.ts

### Subscriptions

 - [id_of_thing6]
 - this.is.id.4
 - this.is.id.5
 - this.is.id.6

### Set State

 - this.is.id.1

### Get State

 - this.is.id.2

### Schedule

 - 19 5 \* \* \*

```

This is the graph generated using the `generateGraph.sh` script:

```mermaid
flowchart LR
   this.is.id.2 -. test.ts .-> this.is.id.1
   this.is.id.4 -- test.ts --> this.is.id.1
   this.is.id.5 -- test.ts --> this.is.id.2
```

## Installation

Requirements are python3 and semgrep:

```
pip install -r requirements.txt
```

## Usage

```
./generateDocs.sh path/to/scripts_directory out_file.md
./generateGraph.sh path/to/scripts_directory out_file.md
```

## Known Problems

The semgrep rules work best with plain string constants, problematic expressions are currently:
 - IDs specified as arrays
 - format-strings for example like that `\`zigbee.0.${foo}\``

## Supported Functions

 - getState
 - getStateAsync
 - setState
 - setStateAsync
 - on
 - schedule
