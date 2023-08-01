<div align="center">
<img src="other\logo.png" alt="Logo" width="350" height="350">

<h2 align="center">
    BBoxCast - VScripts Library for BBox-based Ray Tracing in Portal 2
</h2>
</div>

<!-- # BBoxCast - VScripts Library for BBox-based Ray Tracing in Portal 2 -->

BBoxCast is a VScripts library for performing BBox-based ray tracing in Portal 2. It allows rays to hit entities by using their bounding boxes (BBox), unlike the regular `traceline()` function that only hits world geometry and ignores entities. This library provides enhanced TraceLine capabilities for custom gameplay mechanics, or any vscripts involving ray-based interactions in the Portal 2 environment.

## Comparison with TraceLine()

| Feature                          | bboxcast()                                               | TraceLine()                                              |
|:---------------------------------|:--------------------------------------------------------:|:--------------------------------------------------------:|
| Hits world geometry              | ✔️                                                       | ✔️                                                        |
| Hits entities                    | ✔️                                                       | ❌                                                        |
| Returns hit position             | ✔️                                                       | ❌                                                        |
| Returns hit entity               | ✔️                                                       | ❌                                                        |
| Determines if hit occurred       | ✔️                                                       | ✔️                                                        |
| Determines if hit was in world   | ✔️                                                       | ❌                                                        |
| Returns fraction traversed       | ✔️                                                       | ✔️                                                        |
| Customization                    | ✔️                                                       | ❌                                                        |
| Allows specifying multiple objects to ignore           | ✔️                                                      | ❌                                                      |
| Allows hitting objects that cannot have collisions (like Triggers)     | ✔️                                                      | ❌                                                      |
| Supports tracing through portals                       | ❌ (Rn unavailable)                                     | ❌                                                      |
| Cost                             | Higher                                                   | Lower                                                   |

## Usage

To use the BBoxCast library in your VScript:

1. Include the `bboxcast.nut` file in your VScript.
2. Create an instance of the `bboxcast` class by providing the following parameters:
   - `startpos`: the starting position of the ray.
   - `endpos`: the ending position of the ray.
   - `ignoremask` (optional): an array of entities to be ignored during tracing.
   - `settings` (optional): custom settings for the trace, if any.
3. Utilize the available methods of the `bboxcast` instance to retrieve trace information:
   - `GetStartPos()`: returns the starting position of the ray.
   - `GetEndPos()`: returns the ending position of the ray.
   - `GetHitpos()`: returns the position where the ray hit an entity.
   - `GetEntity()`: returns the entity that was hit by the ray.
   - `DidHit()`: checks if the ray hit any object or entity.
   - `DidHitWorld()`: checks if the ray hit the world (no entity).
   - `GetFraction()`: returns the fraction of the ray's path that was traversed before hitting an entity.

## Customization

The BBoxCast library allows you to customize the tracing process by modifying the `settings` parameter. The available settings include:
- `ignoreClass`: an array of classnames that should be ignored during tracing.
- `priorityClass`: an array of classnames that should be prioritized and not ignored, even if they match the ignored classnames.
- `ErrorCoefficient`: a coefficient that affects the precision of the tracing process.

To apply custom trace settings, simply pass a custom `settings` object when creating an instance of the `bboxcast` class.

## Roadmap

These are the planned improvements for the bboxcast library:
- [ ] Addition of a function to retrieve surface normals.
- [ ] Calculation of angle of incidence for ray collisions.
- [ ] Support for `prop_portal` and `linked_portal_door`.


## Example

To see the BBoxCast library in action, refer to the included example script `example.nut` and the corresponding test map. The example demonstrates how to perform BBox-based ray tracing using the BBoxCast library.

<img src="other\screenshot.png">

## Credit

The BBoxCast library was created by <a href="https://www.youtube.com/@laVashikProductions">laVashik</a>. Please give credit to laVashik when using this library in your projects :>

Protected by the MIT license.