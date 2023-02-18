# VScripts Library for TraceLine with Entity Support in Portal 2

 This repository contains a VScripts library for TraceLine with entity support in Portal 2. This library enables the ray to hit entities by using their bbox, in contrast to the regular *traceline()* function which ignores entities and only hits world geometry.


## How to Use

The main function in this library is `Trace(startpos, endpos, ignoremask=null, filter=false)`, which takes in two arguments, `startpos` and `endpos`, representing the start and end points of the trace. There are two optional parameters, `ignoremask`, which allow for fine-tuning of the trace.

The function returns an array containing two elements, `[hitpos, ent]`, where **hitpos** is the position where the trace ended and **ent** is the entity it collided with. If the trace didn't collide with anything, **ent** will be set to null.

## Settings
There are several settings that can be adjusted to fine-tune the trace, located at the top of the script:

- `Trace_IgnoreClass`: An array of entities to ignore. Can be specified as a mask, for example (trigger_) will ignore all triggers.
- `Trace_PriorityClass`: An array of entities that take priority over Trace_IgnoreClass.
- `traceErrorCoefficient`: The larger the value, the more accurate the trace but the higher the load.


## License

Protected by the MIT license. Credits: required when used _(as laVashik)_
