# Code Style Guidelines
- Constants should be named as upper case string with an underscore between words: EXAMPLE_CONSTANT
- Variables should be named as lower camel case: exampleVariable
- Child tables of the SWS table should be named as upper camel case: SWS.ExampleTable
- Local functions should be named as lower camel case: exampleFunction()
- Table functions should be named as upper camel case: SWS.ExampleTable:ExampleFunction()
- Braces do not have a space between them and their content: (example or 0)
- There should be no spaces before and after concatenations: example.."string"
- Operators have a space before and after: 1 + 2
- Network strings and hook names follow the pattern of SWS.Domain.Descriptor: "SWS.Power.UpdateData"

# Code Guidelines
- Dont use global functions
- Avoid the use of expensive functions such as players.GetAll() or ents.GetAll and reduce the amount of calls if used
- Don't use NW or NW2 Vars
- Try to only network the minimal data necessary
