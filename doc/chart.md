---
layout: default
title: Chart file specifications
description: The specifications of Sunniesnow chart files
math: true
---

# {{ page.title }}
{:.no_toc}

A chart file is a JSON file that contains the chart data.
For an example of a complete chart file,
see [the chart of Sunniesnow Sample](https://github.com/sunniesnow/sunniesnow-sample/blob/master/master.json){:target="_blank"}.

## Table of contents
{:.no_toc}

- toc
{:toc}

## Top-level entries

At the top level of the JSON structure,
it is an object with the following keys.
Required keys are `title`, `artist`, `charter`, `difficultyName`, `difficultyColor`, `difficulty`, and `events`,
although missing values often just trigger a warning instead of an error.

### `title`
{:#chart-title}

- **Type**: non-empty string.

The title of the music.

### `artist`
{:#chart-artist}

- **Type**: non-empty string.

The artist of the music.

### `charter`
{:#chart-charter}

- **Type**: non-empty string.

The charter of the chart.

### `difficultyName`
{:#chart-difficulty-name}

- **Type**: non-empty string.

The name of the difficulty.
In Lyrica equivalents, possible values are
`"Easy"`, `"Normal"`, `"Hard"`, `"Master"`, and `"Special"`.
However, you are free to use other names.

### `difficultyColor`
{:#chart-difficulty-color}

- **Type**: color source.

The color of the difficulty.

A color source may be a string of
[`<color>` CSS data type](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value),
or it may be an integer whose hexadecimal representation is the color.

### `difficulty`
{:#chart-difficulty}

- **Type**: non-empty string.

The difficulty of the chart.
In Lyrica equivalents, possible values are decimal representations
of any integers from 1 to 13.
However, you are free to use other values.

### `difficultySup`
{:#chart-difficulty-sup}

- **Type**: string.
- **Default**: `""`.

A superscript shown near the difficulty.
Usually either an empty string or `"+"`.

### `offset`
{:#chart-offset}

- **Type**: float number.
- **Default**: `0.0`.

The offset of the chart, in seconds.
**Usually, this should be zero.**
This is only used by chart reviewers to adjust the offset after the chart is already made.
Chart makers should generally avoid using this and leave it as zero.

### `sscharter`
{:#chart-sscharter}

- **Type**: `null`, or an object with properties: `version` a string, and `port` an integer.
- **Default**: `null`.

Used for sscharter integration.

### `events`
{:#chart-events}

- **Type**: non-empty array of event objects.

The events of the chart.
To see how an event object is structured,
see [Event object](#event-object).

### `filters`
{:#chart-filters}

- **Type**: object.
- **Default**: `{}`.

This specifies all filters that may be used in the chart.
It is an object with arbitrary string keys
(specifying the label of each filter),
and each value is a filter object,
which contains the definition of the filter.
Events can refer to these filters by their labels
in the [`filters`](#event-filters) object in the event object.

A filter object is an object with the following keys:

- **`gl`**: an object that contains the shader codes for the filter used when the render engine is WebGL.
- **`gpu`**: an object that contains the shader codes for the filter used when the render engine is WebGPU.
- **`resources`**: an object that describes the parameters used by the filter, including textures and uniforms.
- **`antialias`**: one of `"inherit"`, `"on"`, and `"off"` (default: `"inherit"`).
- **`blendMode`**: one of the blend modes supported by the game (default: `"normal"`).
- **`blendRequired`**: boolean (default: `false`).
  Turning this on makes a uniform `uBackTexture` available in the shader
  but will also impact the performance of the filter because there is an additional GPU copy.
- **`resolution`**: either a number or `"inherit"`.
  Default: `"inherit"`.

#### `gl`
{:#filters-gl}

The `gl` object has the following keys:

- **`vertex`**: a string that contains the vertex shader.
- **`fragment`**: a string that contains the fragment shader.

The shader contents can use [Liquid](#liquid-in-shaders).

The following contents are always put at the start of a vertex shader by PixiJS
(where `the-label` is the label of the filter):

```glsl
#define SHADER_NAME the-label-vertex

#ifdef GL_ES // This checks if it is WebGL1
#define in attribute
#define out varying
#endif
precision highp float;
```

The following contents are always put at the start of a fragment shader by PixiJS:

```glsl
#define SHADER_NAME the-label-fragment

#ifdef GL_ES // This checks if it is WebGL1
#define in varying
#define finalColor gl_FragColor
#define texture texture2D
#endif
precision mediump float;
```

Additionally, `out vec4 finalColor;` is deleted if it appears in a WebGL 2 fragment shader.

#### `gpu`
{:#filters-gpu}

The `gpu` object has the following keys:

- **`source`**: a string that contains the shader source.
- **`vertexEntryPoint`**: a string that specifies the entry point function name of the vertex shader.
- **`fragmentEntryPoint`**: a string that specifies the entry point function of the fragment shader.

The entry point functions should be defined in the source.
The source contents can use [Liquid](#liquid-in-shaders).

#### `resources`
{:#filters-resources}

The `resources` object can contain any identifier keys for different resources.
Each resource object is either uniforms or texture.
This part should be understood as the declaration of parameters that the filter needs.
It does not specify their actual values when the filter is used,
but the [`filters`](#event-filters) object of events does.

The keys of a uniforms resource are:

- **`type`**: `"uniforms"`.
- **`uniforms`**: an object whose keys are uniform variable names and whose values are type definitions.
- **`structName` (optional)**:
  a string that specifies the struct type name used in WebGPU shader
  (default: capitalization of the key of this uniforms resource object).

The supported type definitions include `bool`, `i32`, `u32`, `f32`,
and their `vec*<*>` and `mat*x*<*>` variants.
The `f32` type is changed into `float` in WebGL shader,
to change whose precision you need to prefix the type with
`lowp`, `mediump`, or `highp`, which is useless in WebGPU shader.
For example, `highp vec2<f32>` becomes `highp vec2` in WebGL shader
and `vec2<f32>` in WebGPU shader.

The keys of a texture resource are:

- **`type`**: `"texture"`.
- **`samplerName`**: a string specifying the variable name for the sampler in WebGPU shader.
- **`uniformsName`**: a string specifying the variable name for the uniforms struct in WebGPU shader.
- **`uniformsStructName` (optional)**:
  a string that specifies the struct type name for the uniforms struct in WebGPU shader
  (default: capitalization of the value of `uniformsName`).
- **`matrixName`**: a string specifying the variable name for the transformation matrix of the sprite showing this texture.
- **`coordinateSystem`**: one of `"canvas"` and `"chart"`,
  specifying which [coordinate system](#coordinate-system) is used to specify the position
  of the sprite showing this texture.

#### Liquid in shaders

Liquid is a templating language.
Liquid in Sunniesnow is powered by [LiquidJS](https://liquidjs.com).
As shaders are in low-level languages (GLSL or WGSL),
a templating language often helps.

The following Liquid variables are available:

- **`environment`**: one of `"gl-vertex"`, `"gl-fragment"`, and `"gpu"`.
- **`label`**: the label of the filter.
- **`resources`**: the [`resources`](#filters-resources) object defined for the filter.
- **`options`**: an object containing the other options of the filter:
  `antialias`, `blendMode`, `blendRequired`, and `resolution`.
- **`settings`**: user settings of Sunniesnow, whose keys are in camel case.
  See [Sunniesnow help](/game-unstable/help.html) for details.
- **`config`**: global configuration of Sunniesnow.
  Some useful keys are `WIDTH` (canvas width), `HEIGHT` (canvas height),
  `SCALE` (length in canvas coordinate system per unit length in chart coordinate system).

In addition to the standard Liquid filters provided by LiquidJS,
the following Liquid filters are available:

- **`gl_type`**: converts a type definition in [`resources`](#filters-resources) to GLSL type definition.
- **`gpu_type`**: converts a type definition in [`resources`](#filters-resources) to WGSL type definition.

In addition to the standard Liquid tags provided by LiquidJS,
the following Liquid tags are available:

- **`preamble`**: shader codes containing declarations of uniforms
  and definitions of some commonly used functions.
- **`trivial_vertex`**: shader codes defining the main function of a trivial vertex shader.
- **`trivial_fragment`**: shader codes defining the main function of a trivial fragment shader.

The following are examples of the contents replacing
`{% raw %}{% preamble %}{% endraw %}`.
They include declarations of user-defined uniforms specified in `resources`,
taking this as the example `resources` object:

```json
{
	"myUniforms": {
		"type": "uniforms",
		"uniforms": {
			"uScale": "vec2<f32>"
		}
	},
	"uMapTexture": {
		"type": "texture",
		"samplerName": "uMapSampler",
		"uniformsName": "mapUniforms",
		"matrixName": "uMapMatrix",
		"coordinateSystem": "canvas"
	}
}
```

The examples also assume that the label of the filter is `the-label`.
The examples also assume that all the variables and functions are actually used after the preamble;
in real cases, usually many of them are not mentioned in the shader,
which will be omitted in the preamble because some GL program linkers do not accept unused uniforms.
The uniform `uBackTexture` is also included in the examples,
but it is only usable if `blendRequired` is `true`.

The preamble of a vertex shader of WebGL:

```glsl
in vec2 aPosition;
out vec2 vTextureCoord;

uniform highp vec4 uInputSize;
uniform vec4 uInputPixel;
uniform vec4 uInputClamp;
uniform vec4 uOutputFrame;
uniform vec4 uOutputTexture;
uniform sampler2D uTexture;
uniform sampler2D uBackTexture;

vec4 filterVertexPosition(void) {
	vec2 position = aPosition * uOutputFrame.zw + uOutputFrame.xy;
	position.x = position.x * (2.0 / uOutputTexture.x) - 1.0;
	position.y = position.y * (2.0*uOutputTexture.z / uOutputTexture.y) - uOutputTexture.z;
	return vec4(position, 0.0, 1.0);
}

vec2 filterTextureCoord(void) {
	return aPosition * (uOutputFrame.zw * uInputSize.zw);
}

// User-defined uniforms
uniform vec2 uScale;
uniform sampler2D uMapTexture;
uniform mat3 uMapMatrix;
vec2 uMapTextureCoord(void) {
	return (uMapMatrix * vec3(filterTextureCoord(), 1.0)).xy;
}
```

The preamble of a fragment shader of WebGL:

```glsl
in vec2 vTextureCoord;
out vec4 finalColor;

uniform highp vec4 uInputSize;
// ... The rest are the same as a vertex shader
```

The preamble of a shader of WebGPU:

```wgsl
struct GlobalFilterUniforms {
	uInputSize: vec4<f32>,
	uInputPixel: vec4<f32>,
	uInputClamp: vec4<f32>,
	uOutputFrame: vec4<f32>,
	uGlobalFrame: vec4<f32>,
	uOutputTexture: vec4<f32>,
};
@group(0) @binding(0) var<uniform> gfu: GlobalFilterUniforms;
@group(0) @binding(1) var uTexture: texture_2d<f32>;
@group(0) @binding(2) var uSampler: sampler;

fn filterVertexPosition(aPosition: vec2<f32>) -> vec4<f32> {
	var position = aPosition * gfu.uOutputFrame.zw + gfu.uOutputFrame.xy;
	position.x = position.x * (2.0 / gfu.uOutputTexture.x) - 1.0;
	position.y = position.y * (2.0 * gfu.uOutputTexture.z / gfu.uOutputTexture.y) - gfu.uOutputTexture.z;
	return vec4(position, 0.0, 1.0);
}

fn filterTextureCoord(aPosition: vec2<f32>) -> vec2<f32> {
	return aPosition * (gfu.uOutputFrame.zw * gfu.uInputSize.zw);
}

fn globalTextureCoord(aPosition: vec2<f32>) -> vec2<f32> {
	return aPosition.xy / gfu.uGlobalFrame.zw + gfu.uGlobalFrame.xy / gfu.uGlobalFrame.zw;
}

fn getSize() -> vec2<f32> {
	return gfu.uGlobalFrame.zw;
}

// User-defined uniforms
struct MyUniforms {
	uScale: vec2<f32>,
};
@group(1) @binding(0) var<uniform> myUniforms: MyUniforms;
@group(1) @binding(1) var uMapTexture: texture_2d<f32>;
@group(1) @binding(2) var uMapSampler: sampler;
struct MapUniforms {
	uMapMatrix: mat3x3<f32>,
};
@group(1) @binding(3) var<uniform> mapUniforms: MapUniforms;
fn uMapTextureCoord(aPosition: vec2<f32>) -> vec2<f32> {
	return (mapUniforms.uMapMatrix * vec3(filterTextureCoord(aPosition), 1.0)).xy;
}
```

Here are the contents replacing `{% raw %}{% trivial_vertex %}{% endraw %}` in WebGL shader:

```glsl
void main(void) {
	gl_Position = filterVertexPosition();
	vTextureCoord = filterTextureCoord();
}
```

Here are the contents replacing `{% raw %}{% trivial_fragment %}{% endraw %}` in WebGL shader:

```glsl
void main(void) {
	finalColor = texture(uTexture, vTextureCoord);
}
```

Here are the contents replacing `{% raw %}{% trivial_vertex %}{% endraw %}` in WebGPU shader:

```wgsl
struct VSOutput {
	@builtin(position) position: vec4<f32>,
	@location(0) uv: vec2<f32>
};

@vertex fn mainVertex(@location(0) aPosition: vec2<f32>,) -> VSOutput {
	return VSOutput(filterVertexPosition(aPosition), filterTextureCoord(aPosition));
}
```

Here are the contents replacing `{% raw %}{% trivial_fragment %}{% endraw %}` in WebGPU shader:

```wgsl
@fragment fn mainFragment(@location(0) uv: vec2<f32>, @builtin(position) position: vec4<f32>) -> @location(0) vec4<f32> {
	return textureSample(uTexture, uSampler, uv);
}
```

## Event object

An event object is an object with the required keys `type`, `time`, and `properties`,
and optional keys `timeDependent`.
Some types of events may also have an optional key `filters`.
Missing a required key will trigger a warning, and this event object will be ignored.

### `type`
{:#event-type}

- **Type**: string (with a limited set of possible values).

Here is a list of possible values:

- [`"tap"`](#tap),
- [`"hold"`](#hold),
- [`"drag"`](#drag),
- [`"flick"`](#flick),
- [`"dragFlick"`](#drag-flick),
- [`"headOnlyHold"`](#head-only-hold),
- [`"placeholder"`](#placeholder),
- [`"bgNote"`](#bg-note),
- [`"bigText"`](#big-text),
- [`"grid"`](#grid),
- [`"hexagon"`](#hexagon),
- [`"checkerboard"`](#checkerboard),
- [`"diamondGrid"`](#diamond-grid),
- [`"pentagon"`](#pentagon),
- [`"turntable"`](#turntable),
- [`"hexagram"`](#hexagram),
- [`"image"`](#image),
- [`"globalSpeed"`](#global-speed),
- [`"effectBackground"`](#effect-background),
- [`"effectTopLeftHud"`](#effect-top-left-hud),
- [`"effectTopRightHud"`](#effect-top-right-hud),
- [`"effectTopCenterHud"`](#effect-top-center-hud),
- [`"effectProgressBar"`](#effect-progress-bar),
- [`"effectTipPoint"`](#effect-tip-point),
- [`"effectMultiple"`](#effect-multiple).

See [Event types](#event-types) for more information.

### `time`
{:#event-time}

- **Type**: float number.

This specifies the time of the event, in seconds,
measured from the start of the music.

It may be negative or greater than the duration of the music,
but take note that these events may not be actually included in the chart
unless the player specifies [start and end](/game/help.html#start-and-end) to a larger range.

### `properties`
{:#event-properties}

- **Type**: object.

The structure of this object depends on the value of `type`.
Some of the entries of this object are required, while others are optional.
If required entries are missing, a warning will be triggered,
and this event object will be ignored.
If there are unknown entries, a warning will be triggered.
See [Event types](#event-types) for more information.

#### Common to all notes
{:#note-properties}

These are the properties that are common to all types of notes
(`tap`, `hold`, `drag`, `flick`, `dragFlick`, `headOnlyHold`, `bgNote`):

- **`x`**: float number.
- **`y`**: float number.
- **`tipPoint` (optional)**: nullable string (default: `null`).
- **`size` (optional)**: float number (default: `1.0`).
- **`fake`**: boolean (default: `false`; not applicable to `bgNote`).
- **`doubleLine`**: one of `"user"`, `"always"`, and `"never"` (default: `"user"`; not applicable to `bgNote`).

The properties `x` and `y` specify the judgement coordinates of the note,
in the chart coordinate system.
See [Coordinate system](#coordinate-system) for more information.

If `tipPoint` is not `null`,
then the note will be connected by a tip point.
See [Tip points](#tip-points) for more information.

The property `size` scales the size of the judgement area.

The property `fake` specifies whether the note is fake.
Fake notes do not have judgements, combos, and FX.

The property `doubleLine` specifies whether the note can have simultaneity hints.

#### Common to all background patterns
{:#bg-pattern-properties}

These are the properties that are common to all background patterns
(`grid`, `hexagon`, `checkerboard`, `diamondGrid`, `pentagon`, `turntable`, `hexagram`, `bigText`):

- **`duration` (optional)**: non-negative float number (default: `0.0`).

The property `duration` specifies the duration of the background pattern, in seconds.
It can be zero, but it is not recommended.

Only one background pattern can be shown at a time.
If two background patterns overlap in time,
the later one will override the earlier one.

#### Common to all effects
{:#effect-properties}

These are the properties that are common to all effects
(`effectBackground`, `effectTopLeftHud`, `effectTopRightHud`,
`effectTopCenterHud`, `effectProgressBar`, `effectTipPoint`, `effectMultiple`):

- **`duration`**: positive float number.

The property `duration` specifies the duration of the effect, in seconds.

### `timeDependent`
{:#event-time-dependent}

- **Type**: object.

It is used to make the event appear moving, changing size, etc.,
but it does not affect the judgement.
Each type of events has its own supported keys in `timeDependent`,
and all of them are optional.
Any additional keys will trigger a warning and be ignored.
The value of each entry in the `timeDependent` object is of one of the following three types:

- **(uninterpolable) string**:
  an object with optional keys `value` and `dataPoints`,
  where `value` is a string, and `dataPoints` is an array of objects with keys `time` and `value`,
  where `time` is a float number and `value` is a string.
- **uninterpolable number**:
  an object with optional keys `value` and `dataPoints`,
  where `value` is a float number, and `dataPoints` is an array of objects with keys `time` and `value`,
  where `time` and `value` are float numbers.
- **(interpolable) number**:
  an object with optional keys `speed`, `value` and `dataPoints`,
  where `speed` and `value` are float numbers, and `dataPoints` is an array of objects with keys `time`, `value`,
  where `time` and `value` are float numbers.

For an uninterpolable time-dependent property,
the top-level `value` is the value of the property before the earliest `time` in `dataPoints`.
Then, each item in `dataPoints` makes an abrupt change at the specified `time`
into the specified `value`.

For an interpolable time-dependent property,
the top-level `value` is the value of the property **right before**
the [`time`](#time) of the event itself.
The items in `dataPoints`, together with the top-level `value`,
defines a piecewise linear function
that specifies how the property changes over time.
There can be different data points with the same time,
which makes the property change abruptly at that time.
The rate of change of the property before the earliest `time` in `dataPoints`
is specified by `speed`.
The value of the property after the latest `time` in `dataPoints`
is kept the same as the value at the latest `time`.

In [event types](#event-types),
the supported keys of `timeDependent` for each type of event
and their corresponding types and their default `value`s and `speed`s are documented.
If the default `value` is not specified,
it is taken from the value in the entry in `properties` with the same key.
If the default `speed` is not specified,
it is `0.0` for interpolable numbers.

Some of the supported keys are shared by multiple types of events.
To avoid verbosity, they are documented here,
and will not be explained again in the event types.

#### `x`, `y`

These are used to translate the event around in space.
The coordinate system used by them is not consistent for all events,
but the rule of thumb is that all events that are affected by
player settings about mirroring (`horizontal-flip` and `vertical-flip`)
use the chart coordinate system,
and others use the canvas coordinate system.
See [Coordinate system](#coordinate-system) for more information.

#### `opacity`

It is used to control the opacity of the event.
When the value is `0.0`, the event is completely transparent,
and when the value is `1.0`, the event is completely opaque.

#### `size`

It is used to control the visual size of the event.
When the value is `0.0`, the event is not shown at all,
and when the value is `1.0`, the event is at its normal size.

#### `scaleX`, `scaleY`

They are similar to `size`, but they can control the size of the event anisotropically.
The reason to have `size` when we have `scaleX` and `scaleY`
is that `size` can inherit its default value from the `size` property in `properties`,
while `scaleX` and `scaleY` cannot.
If both `size` and `scaleX` (or `scaleY`) are specified,
then the effective scale is the product of `size` and `scaleX` (or `scaleY`).

#### `skewX`, `skewY`

Skewing is a transformation that distorts the object by rotating it differently at each point.
the properties `skewX` and `skewY` sets the skew factor in radians.

#### `rotation`

{% katexmm %}
It is used to control the rotation of the event.
It is in **radians**, and the positive direction is not consistent for all events.
The rule of thumb is that all events that are affected by
player settings about mirroring (`horizontal-flip` and `vertical-flip`)
have the positive direction counterclockwise,
and others have the positive direction clockwise.
This is because the chart coordinate system has the $y$-axis pointing upwards,
but the canvas coordinate system has the $y$-axis pointing downwards.
{% endkatexmm %}

#### `text`

It is used to control the text displayed on the event.

#### `tintRed`, `tintGreen`, `tintBlue`

It is used for simple change in the colors.
It is equivalent to a color matrix whose main diagonal elements
are the three values specified by these three properties
(and leaves the alpha channel unchanged).

Their values cannot be smaller than `0.0` or larger than `1.0`.

#### `blendMode`

The blend mode. Available values are:
`"normal"`,
`"add"`,
`"multiply"`,
`"screen"`,
`"darken"`,
`"lighten"`,
`"erase"`,
`"color-dodge"`,
`"color-burn"`,
`"linear-burn"`,
`"linear-dodge"`,
`"linear-light"`,
`"hard-light"`,
`"soft-light"`,
`"pin-light"`,
`"difference"`,
`"exclusion"`,
`"overlay"`,
`"saturation"`,
`"color"`,
`"luminosity"`,
`"normal-npm"`,
`"add-npm"`,
`"screen-npm"`,
`"none"`,
`"subtract"`,
`"divide"`,
`"vivid-light"`,
`"hard-mix"`,
`"negation"`,
`"min"`,
`"max"`.

#### Common to all notes
{:#note-time-dependent}

These are the time-dependent properties that are common to all types of notes
(`tap`, `hold`, `drag`, `flick`, and `bgNote`):

- **`x`**: number (default `speed`: `0.0`).
- **`y`**: number (default `speed`: `0.0`).
- **`circle`**: number (default `value`: `0.0`; default `speed`: `1.0`).
- **`opacity`**: number (default `value`: `1.0`).
- **`size`**: number (default `value`: `1.0`).
- **`scaleX`**: number (default `value`: `1.0`).
- **`scaleY`**: number (default `value`: `1.0`).
- **`skewX`**: number (default `value`: `0.0`).
- **`skewY`**: number (default `value`: `0.0`).
- **`rotation`**: number (default `value`: `0.0`).
- **`tintRed`**: number (default `value`: `1.0`).
- **`tintGreen`**: number (default `value`: `1.0`).
- **`tintBlue`**: number (default `value`: `1.0`).
- **`blendMode`**: string (default `value`: `"normal"`).
- **`circleOpacity`**: number (default `value`: `1.0`).
- **`circleScaleX`**: number (default `value`: `1.0`).
- **`circleScaleY`**: number (default `value`: `1.0`).
- **`circleSkewX`**: number (default `value`: `0.0`).
- **`circleSkewY`**: number (default `value`: `0.0`).
- **`circleRotation`**: number (default `value`: `0.0`).
- **`circleTintRed`**: number (default `value`: `1.0`).
- **`circleTintGreen`**: number (default `value`: `1.0`).
- **`circleTintBlue`**: number (default `value`: `1.0`).
- **`circleBlendMode`**: string (default `value`: `"normal"`).

The properties `x` and `y` are used to change the spatial coordinates of the event
so that it can appear moving.
They share the same coordinate system (the chart coordinate system)
as the `x` and `y` in `properties`.
Note that anything in `timeDependent` will not affect the judgement of the event,
so even if the `x` and `y` values change over time,
the judgement position is still the position specified by `x` and `y` in `properties`.

The `rotation` property has the positive direction **counterclockwise**.

The property `circle` is used to control the radius of the shrinking circle.
When the value is `0.0`, the radius is at its minimum
(coinciding with the note).
The value at which the radius is at its maximum is dependent
on the speed set by the player in the game settings.
If the player sets the speed to `1.0`,
then the value at which the radius is at its maximum is `-1.0`
(it is negative because we want the circle to shrink when the speed is positive).
This value is then inversely scaled by the speed set by the player
in the game settings.
When the value is smaller than the value at which the radius is at its maximum,
the note is not shown at all.

The properties `circleOpacity`, `circleRotation`, `circleTintRed`, `circleTintGreen`, `circleTintBlue`,
and `circleBlendMode`
are the time-dependent properties to change the visual appearance of the shrinking circle.
Their effects are similar to the properties `opacity`, `rotation`, `tintRed`, `tintGreen`, `tintBlue`, and `blendMode`,
but applied to the shrinking circle instead of the note itself.
The chart cannot control the coordinates of the circle
because it is either the same as the note or fixed at the judgement position
(depending on the player setting `circle-moves-with-note`).

The base scaling of the circle is the same as `size`,
so there is no `circleSize` property
to ensure visual consistency of the circle size and the note size.
However, `circleScaleX` and `circleScaleY` can be used to scale the circle
on top of the base scaling,
and they are not related to the `scaleX` and `scaleY` properties of the note.

#### Common to all background patterns
{:#bg-pattern-time-dependent}

These are the time-dependent properties that are common to all background patterns
(`grid`, `hexagon`, `checkerboard`, `diamondGrid`, `pentagon`, `turntable`, `hexagram`, `bigText`):

- **`x`**: number (default `speed`: `0.0`).
- **`y`**: number (default `speed`: `0.0`).
- **`opacity`**: number (default `value`: `1.0`).
- **`size`**: number (default `value`: `1.0`).
- **`scaleX`**: number (default `value`: `1.0`).
- **`scaleY`**: number (default `value`: `1.0`).
- **`skewX`**: number (default `value`: `0.0`).
- **`skewY`**: number (default `value`: `0.0`).
- **`rotation`**: number (default `value`: `0.0`).
- **`tintRed`**: number (default `value`: `1.0`).
- **`tintGreen`**: number (default `value`: `1.0`).
- **`tintBlue`**: number (default `value`: `1.0`).
- **`blendMode`**: string (default `value`: `"normal"`).

The `x` and `y` properties use the same coordinate system as the notes
(the chart coordinate system).
They are used to translate the background pattern around in space.
The `rotation` property has the positive direction **counterclockwise**.

#### Common to all effects
{:#effect-time-dependent}

These are the time-dependent properties that are common to all effects
(`effectBackground`, `effectTopLeftHud`, `effectTopRightHud`,
`effectTopCenterHud`, `effectProgressBar`, `effectTipPoint`, `effectMultiple`):

- **`opacity`**: number (default `value`: `1.0`).
- **`size`**: number (default `value`: `1.0`).
- **`scaleX`**: number (default `value`: `1.0`).
- **`scaleY`**: number (default `value`: `1.0`).
- **`skewX`**: number (default `value`: `0.0`).
- **`skewY`**: number (default `value`: `0.0`).
- **`rotation`**: number (default `value`: `0.0`).
- **`tintRed`**: number (default `value`: `1.0`).
- **`tintGreen`**: number (default `value`: `1.0`).
- **`tintBlue`**: number (default `value`: `1.0`).
- **`blendMode`**: string (default `value`: `"normal"`).

These properties affect the visual appearances of the things to which the effects are applied.
The `rotation` property has the positive direction **clockwise**.

### `filters`
{:#event-filters}

Most event types accept filters.
The value of `filters` is an array of filter objects with the following keys:

- **`time`**: number, the time at which the filter starts being active.
- **`label`**: string, the label of the filter, determining which filter to use,
  corresponding to the label set in chart [`filters`](#chart-filters).
- **`duration`**: number, the duration for which the filter stays active.
- **`timeDependent`**: object, whose keys specify how the parameters (uniforms, textures, and other parameters)
  of the shader change over time.

The `timeDependent` object may have the following keys:

- **`paddingX`**: time-dependent number.
- **`paddingY`**: time-dependent number.
- **`<uniforms>.<uniform>`**: time-dependent number (for `f32`) or time-dependent array (for `vec*<*>` and `mat*x*<*>`).
- **`<texture>`**: time-dependent string.
- **`<texture>.*`**: time-dependent number, where `*` may be `x`, `y`, `width`, `height`, `rotation`,
  `scaleX`, `scaleY`, `skewX`, `skewY`, `anchorX`, `anchorY`.

A time-dependent number or array is an object that may contain the following keys:

- **`value`**.
- **`dataPoints`**.
- **`scaleBy`**: one of `"none"`, `"chartUnitWidth"`, `"chartUnitHeight"`, `"canvasWidth"`,
  `"canvasHeight"` (default: `"none"`).

The `value` and `dataPoints` key have the same convention and semantics as
those for [`timeDependent`](#event-time-dependent) objects.
The only difference is that uniforms may be time-dependent arrays,
for which `value` and `value` in `dataPoints` elements should be arrays of correct sizes.

A time-dependent string is the same as a time-dependent string in [`timeDependent`](#event-time-dependent) objects.

The placeholder `<uniforms>` and `<texture>` correspond to keys in chart [`filters`](#chart-filters) object.
The placeholder `<uniform>` corresponds to keys in the type definition of the uniform variables in chart `filters` object.

When `scaleBy` is not `"none"`, the actual values seen by the shaders are scaled by a constant.
For `"chartUnitWidth"` or `"chartUnitHeight"`, the magnitude of the scaling factor
is the length in canvas coordiante system per unit length in chart coordinate system,
and it is negative if the chart is flipped in the corresponding direction
(`"chartUnitWidth"` has negative scale when horizontal flip is on; similarly for `"chartUnitHeight"`).
For `"canvasWidth"` or `"canvasHeight"`, the scaling factor is the total width or height
of the canvas in the canvas coordinate system.

The parameters `paddingX` and `paddingY` specifies a larger texture area for the shader to work with
than the original visual appearance of the affected UI elements.
The rationale is that some filters need writing to pixels outside the original UI elements;
for example, a blurring effect makes the colors spread out so that the UI elements appear larger.

The value of `<texture>` is the filename in `story` dir of the level file
from which the texture is loaded, similarly to the `filename` property of [`image`](#image) events.
The other `<texture>.*` values are also similar to those in the `timeDependent` object of an `image` event.

Because filters basically replace a few layers with a whole rendered texture,
blend modes of objects inside those layers may not work properly.

## Event types

The following sections describe each different [`type`](#type) of event,
including how their [`properties`](#properties) are structured.

### `tap`
{:#tap}

- **`type`**: `"tap"`.
- **`properties`** except the [common ones](#note-properties):
  - **`text` (optional)**: string (default: `""`).
- **`timeDependent`** except the [common ones](#note-time-dependent):
  - **`text`**: string.
- **`filters`**: yes.

A `tap` event is a tap note.

The property `text` specifies the text displayed on the note.

### `hold`
{:#hold}

- **`type`**: `"hold"`.
- **`properties`** except the [common ones](#note-properties):
  - **`text` (optional)**: string (default: `""`).
  - **`duration`**: positive float number.
- **`timeDependent`** except the [common ones](#note-time-dependent):
  - **`text`**: string.
- **`filters`**: yes.

A `hold` event is a hold note.

The property `duration` specifies the duration of the hold note, in seconds.

The property `text` specifies the text displayed on the note.

### `drag`
{:#drag}

- **`type`**: `"drag"`.
- **`properties`** except the [common ones](#note-properties): none.
- **`timeDependent`** except the [common ones](#note-time-dependent): none.
- **`filters`**: yes.

A `drag` event is a drag note.

### `flick`
{:#flick}

- **`type`**: `"flick"`.
- **`properties`** except the [common ones](#note-properties):
  - **`angle`**: float number or array of at least one float numbers.
  - **`text` (optional)**: string (default: `""`).
- **`timeDependent`** except the [common ones](#note-time-dependent):
  - **`text`**: string.
- **`filters`**: yes.

A `flick` event is a flick note.

The property `angle` specifies the angle(s) of the flick note, in **radians**.
Zero angle is to the right, and increasing angle is counterclockwise
(as in conventions of mathematics about polar coordinates).

The property `text` specifies the text displayed on the note.

### `dragFlick`
{:#drag-flick}

- **`type`**: `"dragFlick"`.
- **`properties`** except the [common ones](#note-properties):
  - **`angle`**: float number or array of at least one float numbers.
- **`timeDependent`** except the [common ones](#note-time-dependent): none.
- **`filters`**: yes.

A `dragFlick` event is a drag-flick note.
The property `angle` specifies the angle(s) of the drag-flick note, in **radians**.
Zero angle is to the right, and increasing angle is counterclockwise.

Lyrica does not have drag-flick notes,
but Sunniesnow supports them.

### `headOnlyHold`
{:#head-only-hold}

- **`type`**: `"headOnlyHold"`.
- **`properties`** except the [common ones](#note-properties):
  - **`text` (optional)**: string (default: `""`).
  - **`duration`**: positive float number.
- **`timeDependent`** except the [common ones](#note-time-dependent):
  - **`text`**: string.
- **`filters`**: yes.

A `headOnlyHold` event is a head-only hold note.
The property `duration` specifies the duration of the head-only hold note, in seconds.

### `placeholder`
{:#placeholder}

- **`type`**: `"placeholder"`.
- **`properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
- **`timeDependent`**: none.
- **`filters`**: no.

A `placeholder` event basically does nothing,
but it can have a tip point by specifying `tipPoint`.
See [Tip points](#tip-points) for more information.

### `bgNote`
{:#bg-note}

- **`type`**: `"bgNote"`.
- **`properties`** except the [common ones](#note-properties):
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
  - **`text` (optional)**: string (default: `""`).
- **`timeDependent`** except the [common ones](#note-time-dependent):
  - **`text`**: string.
- **`filters`**: yes.

A `bgNote` event is a background note (often called an "ink" by Lyrica players).

The property `duration` specifies the duration of the background note, in seconds.

The property `text` specifies the text displayed on the background note.

It can still be connected by a tip point
if the `tipPoint` property is specified,
but background notes cannot have tip points in Lyrica.

The property `size` does nothing
(but it may be useful because it is the default `value` of the `size` option
in `timeDependent`).

### `bigText`
{:#big-text}

- **`type`**: `"bigText"`.
- **`properties`** except the [common ones](#bg-pattern-properties):
  - **`text`**: string.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent):
  - **`text`**: string.
- **`filters`**: yes.

A `bigText` event is a big text.
It is one kind of background patterns
that are displayed in the center of the screen.

The property `text` specifies the text displayed on the big text.

### `grid`
{:#grid}

- **`type`**: `"grid"`.
- **`properties`** except the [common ones](#bg-pattern-properties): none.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent): none.
- **`filters`**: yes.

A `grid` event is a grid.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The intersections of grid lines have $x$-coordinates and $y$-coordinates
divisible by $25$,
with x-coordinates ranging from $-100$ to $100$
and y-coordinates ranging from $-50$ to $50$,
so there are $45$ intersections in total.
{% endkatexmm %}

### `hexagon`
{:#hexagon}

- **`type`**: `"hexagon"`.
- **`properties`** except the [common ones](#bg-pattern-properties): none.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent): none.
- **`filters`**: yes.

A `hexagon` event is a hexagon.
It is one kind of background patterns
that are displayed in the center of the screen.

There are three hexagons with different radii.
Here list the vertices of each of them:

{% katexmm %}
- Largest: $(\pm50/\sqrt3,50)$, $(\pm100/\sqrt3,0)$, $(\pm50/\sqrt3,-50)$.
- Middle: $(0,\pm50)$, $(\pm75/\sqrt3,25)$, $(\pm75/\sqrt3,-25)$.
- Smallest: $(\pm37.5/\sqrt3,37.5)$, $(\pm75/\sqrt3,0)$, $(\pm37.5/\sqrt3,-37.5)$.
{% endkatexmm %}

### `checkerboard`
{:#checkerboard}

- **`type`**: `"checkerboard"`.
- **`properties`** except the [common ones](#bg-pattern-properties): none.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent): none.
- **`filters`**: yes.

A `checkerboard` event is a checkerboard.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The checkerboard has $4$ rows of cells and $4$ columns of cells.
The top-left cell has its center at $(-37.5,37.5)$.
The bottom-right cell has its center at $(37.5,-37.5)$.
The side length of each cell is $25$.
{% endkatexmm %}

### `diamondGrid`
{:#diamond-grid}

- **`type`**: `"diamondGrid"`.
- **`properties`** except the [common ones](#bg-pattern-properties): none.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent): none.
- **`filters`**: yes.

A `diamondGrid` event is a diamond grid.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The intersections of grid lines are
$(25,75)$, $(75,75)$, $(0,50)$, $(50,50)$, $(100,50)$, $(25,25)$,
$(75,25)$, $(125,25)$, $(0,0)$, $(50,0)$, $(100,0)$,
and their reflections about the $x$-axis and/or the $y$-axis.
There are $35$ intersections in total.
{% endkatexmm %}

### `pentagon`
{:#pentagon}

- **`type`**: `"pentagon"`.
- **`properties`** except the [common ones](#bg-pattern-properties): none.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent): none.
- **`filters`**: yes.

A `pentagon` event is a pentagon.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The explicit expressions for the vertices of the pentagon are
$$(0,50),\quad
\left(\pm10\sqrt{50-10\sqrt5},50\sqrt5-100\right),\quad
\left(\pm20\sqrt{25-10\sqrt5},-50\right).$$
The explicit expression for the center of the pentagon is $\left(0,20\sqrt5-50\right)$.

The numerical values of the vertices are approximately
$(0,50)$, $(\pm52.57,11.80)$, and $(\pm32.49,-50)$.
The numerical value of the center is approximately $(0,-5.28)$.
{% endkatexmm %}

### `turntable`
{:#turntable}

- **`type`**: `"turntable"`.
- **`properties`** except the [common ones](#bg-pattern-properties): none.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent): none.
- **`filters`**: yes.

A `turntable` event is a turntable.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The turntable has two circles concentric at $(0,0)$.
Their radii are respectively $28$ and $50$.
{% endkatexmm %}

### `hexagram`
{:#hexagram}

- **`type`**: `"hexagram"`.
- **`properties`** except the [common ones](#bg-pattern-properties): none.
- **`timeDependent`** except the [common ones](#bg-pattern-time-dependent): none.
- **`filters`**: yes.

A `hexagram` event is a hexagram.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The turntable consists of two triangles whose centers are both $(0,0)$
and radii are both $50$ (side lengths $25\sqrt3$).
One of the triangles is upright, and the other is upside-down.
{% endkatexmm %}

### `image`
{:#image}

- **`type`**: `"image"`.
- **`properties`**:
  - **`filename`**: non-empty string.
  - **`x`**: float number.
  - **`y`**: float number.
  - **`width`**: float number.
  - **`height` (optional)**: float number.
  - **`duration`**: non-negative float number.
  - **`above` (optional)**: the layer above which the image is shown (default: `"bgPattern"`).
  - **`coordinateSystem` (optional)**: `"chart"` or `"canvas"` (default: `"chart"`).
  - **`mirrorable` (optional)**: boolean (default: `coordinateSystem === "chart"`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`z`**: uninterpolable number (default `value`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`).
  - **`width`**: number (default `speed`: `0.0`).
  - **`height`**: number (default `speed`: `0.0`).
  - **`scaleX`**: number (default `value`: `1.0`).
  - **`scaleY`**: number (default `value`: `1.0`).
  - **`skewX`**: number (default `value`: `0.0`).
  - **`skewY`**: number (default `value`: `0.0`).
  - **`anchorX`**: number (default `value`: `0.5`).
  - **`anchorY`**: number (default `value`: `0.5`).
  - **`rotation`**: number (default `value`: `0.0`).
  - **`tintRed`**: number (default `value`: `1.0`).
  - **`tintGreen`**: number (default `value`: `1.0`).
  - **`tintBlue`**: number (default `value`: `1.0`).
  - **`blendMode`**: string (default `value`: `"normal"`).
- **`filters`**: yes.

Displaying an image.

The properties `x` and `y` specify the coordinates of the image.
The coordinate system is dependent on the value of the `coordinateSystem` property,
which can be either `"chart"` or `"canvas"`.
If it is `"chart"`, the coordinate system is the chart coordinate system,
which is the same as the coordinate system used by notes.
If it is `"canvas"`, the coordinate system is the canvas coordinate system.
For details of the chart coordinate system and the canvas coordinate system,
see [Coordinate system](#coordinate-system).

The property `width` and `height` specify the size of the image.
If `height` is omitted, it is set to keep the original aspect ratio of the image.
When `coordinateSystem` is `"chart"`, they have the same unit length as
the chart coordinate system.
When `coordinateSystem` is `"canvas"`, the unit length of `width` is the same as the width of the screen,
and the unit length of `height` is the same as the height of the screen.
The property `scaleX` and `scaleY` can scale the image on top of the size set by `width` and `height`.

The property `filename` specifies the filename of the image
inside `story/` directory in the level file
(special path components like `.` and `..` are not allowed).

The property `duration` specifies the duration of the image, in seconds.

The property `above` specifies the layer above which the image is shown.
Possible values are:
`"none"`, `"background"`, `"bgPattern"`, `"hud"`, `"fx"`, `"judgementLine"`,
`"bgNotes"`, `"notes"`, `"circles"`, `"tipPoints"`, and `"fxFront"`.

In the time-dependent properties,
the property `z` specifies the z-index of the image,
which controls the whether an image is displayed above or below other images.
For images with the same `above`,
those with larger `z` values are displayed above images with smaller `z` values.

The properties `anchorX` and `anchorY` specify the anchor point of the image,
which is the point that the image rotates around
and the point whose coordinates are specified by `x` and `y`.
The default values of `anchorX` and `anchorY` are both `0.5`,
which means the anchor point is at the center of the image.
If they are both `0.0`, the anchor point is at the top-left corner of the image.

The `rotation` property has the positive direction **counterclockwise**
if `coordinateSystem` is `"chart"`,
and the positive direction is **clockwise** if `coordinateSystem` is `"canvas"`.

The `mirrorable` property specifies whether the image contents can be mirrored by the player settings
`horizontal-flip` and `vertical-flip`.
By default, it is `true` if `coordinateSystem` is `"chart"`, and `false` if `coordinateSystem` is `"canvas"`.
If it is `true`, then the image contents can get mirrored by these player settings;
otherwise, the image contents will not be mirrored.
Notice that this property only affects the image contents
and that whether its position and rotation can be mirrored by these player settings
is always determined by `coordinateSystem`.

### `globalSpeed`
{:#global-speed}

- **`type`**: `"globalSpeed"`.
- **`properties`**:
  - **`speed`**: float number.
- **`timeDependent`**: none.
- **`filters`**: no.

Controls the global speed (of shrinking circles).
You can set it to zero or negative values.

The current global speed is used to scale the speed of shrinking circles of all notes
before the earliest data point in their time-dependent `circle` properties.
After the earliest data point,
the global speed cannot affect the radii of the circles.

Technically, you can use the time-dependent `circle` property
in the notes to achieve any effects that this event can achieve,
but this event is provided to reduce file sizes of chart files.

### `effectBackground`
{:#effect-background}

- **`type`**: `"effectBackground"`.
- **`properties`** except the [common ones](#effect-properties): none.
- **`timeDependent`** except the [common ones](#effect-time-dependent):
  - **`x`**: number (default `value`: `0.5`).
  - **`y`**: number (default `value`: `0.5`).
- **`filters`**: yes.

This event applies effects to the background.

Multiple effects can happen at the same time,
but if their time-dependent properties conflict,
later ones will override earlier ones
(only the conflict properties are overwritten;
the non-conflict properties from all effect events can be effective at the same time).

The time-dependent properties `x` and `y` are in the canvas coordinate system,
and it specifies the position of the center of the background.
The time-dependent property `rotation` has the positive direction **clockwise**.

### `effectTopLeftHud`
{:#effect-top-left-hud}

- **`type`**: `"effectTopLeftHud"`.
- **`properties`** except the [common ones](#effect-properties): none.
- **`timeDependent`** except the [common ones](#effect-time-dependent):
  - **`x`**: number (default `value`: `0.0`).
  - **`y`**: number (default `value`: `0.0`).
  - **`data`**: string.
- **`filters`**: yes.

This event applies effects to the top left HUD.

Multiple effects can happen at the same time,
but if their time-dependent properties conflict,
later ones will override earlier ones
(only the conflict properties are overwritten;
the non-conflict properties from all effect events can be effective at the same time).

The time-dependent properties `x` and `y` are in the canvas coordinate system,
and it specifies the position of the top left corner of the top left HUD.
The time-dependent property `rotation` has the positive direction **clockwise**.

The time-dependent property `data` sets the text shown in the top left HUD,
which overrides the text set by the player settings.

### `effectTopRightHud`
{:#effect-top-right-hud}

- **`type`**: `"effectTopRightHud"`.
- **`properties`** except the [common ones](#effect-properties): none.
- **`timeDependent`** except the [common ones](#effect-time-dependent):
  - **`x`**: number (default `value`: `1.0`).
  - **`y`**: number (default `value`: `0.0`).
  - **`data`**: string.
- **`filters`**: yes.

This event applies effects to the top right HUD.

Multiple effects can happen at the same time,
but if their time-dependent properties conflict,
later ones will override earlier ones
(only the conflict properties are overwritten;
the non-conflict properties from all effect events can be effective at the same time).

The time-dependent properties `x` and `y` are in the canvas coordinate system,
and it specifies the position of the top right corner of the top right HUD.
The time-dependent property `rotation` has the positive direction **clockwise**.

The time-dependent property `data` sets the text shown in the top right HUD,
which overrides the text set by the player settings.

### `effectTopCenterHud`
{:#effect-top-center-hud}

- **`type`**: `"effectTopCenterHud"`.
- **`properties`** except the [common ones](#effect-properties): none.
- **`timeDependent`** except the [common ones](#effect-time-dependent):
  - **`x`**: number (default `value`: `0.5`).
  - **`y`**: number (default `value`: `0.0`).
  - **`data`**: string.
- **`filters`**: yes.

This event applies effects to the top center HUD.

Multiple effects can happen at the same time,
but if their time-dependent properties conflict,
later ones will override earlier ones
(only the conflict properties are overwritten;
the non-conflict properties from all effect events can be effective at the same time).

The time-dependent properties `x` and `y` are in the canvas coordinate system,
and it specifies the position of the center of the top edge of the top center HUD.
The time-dependent property `rotation` has the positive direction **clockwise**.

The time-dependent property `data` sets the text shown in the top center HUD,
which overrides the text set by the player settings.

### `effectProgressBar`
{:#effect-progress-bar}

- **`type`**: `"effectTopRightHud"`.
- **`properties`** except the [common ones](#effect-properties): none.
- **`timeDependent`** except the [common ones](#effect-time-dependent):
  - **`x`**: number (default `value`: `0.5`).
  - **`y`**: number (default `value`: `1.0`).
  - **`data`**: number.
- **`filters`**: yes.

This event applies effects to the progress bar.

Multiple effects can happen at the same time,
but if their time-dependent properties conflict,
later ones will override earlier ones
(only the conflict properties are overwritten;
the non-conflict properties from all effect events can be effective at the same time).

The time-dependent properties `x` and `y` are in the canvas coordinate system,
and it specifies the position of the center of the top edge of the top center HUD.
The time-dependent property `rotation` has the positive direction **clockwise**.

The time-dependent property `data` sets the progress bar value,
with `0.0` meaning just starting and `1.0` meaning finished.
It only affects the appearance of the progress bar instead of the actual progress of the music.

### `effectTipPoint`
{:#effect-tip-point}

- **`type`**: `"effectTipPoint"`.
- **`properties`** except the [common ones](#effect-properties):
  - **`tipPoint`**: string.
- **`timeDependent`** except the [common ones](#effect-time-dependent):
  - **`x`**: number (default `value`: `0.0`).
  - **`y`**: number (default `value`: `0.0`).
- **`filters`**: yes.

This event applies effects to a tip point,
specified by the `tipPoint` property.

The time-dependent properties `x` and `y` are in chart coordinates,
different from those of other effect events.
The time-dependent property `rotation` has the positive direction **counterclockwise**.

### `effectMultiple`
{:#effect-multiple}

- **`type`**: `"effectMultiple"`.
- **`properties`** except the [common ones](#effect-properties):
  - **`from` (optional)**: string (default: `"imagesAboveNone"`).
  - **`to` (optional)**: string (default: `"imagesAboveFxFront"`).
- **`timeDependent`** except the [common ones](#effect-time-dependent):
  - **`x`**: number (default `value`: `0.5`).
  - **`y`**: number (default `value`: `0.5`).
  - **`pivotX`**: number (default `value`: `0.5`).
  - **`pivotY`**: number (default `value`: `0.5`).
- **`filters`**: yes.

This event applies effects to multiple layers of UI elements,
including the background, the notes, the tip points, etc.
To choose what are affected, use the `from` and `to` properties.
Possible values for `from` and `to` are:
`"imagesAboveNone"`, `"background"`, `"imagesAboveBackground"`,
`"bgPattern"`, `"imagesAboveBgPattern"`, `"hud"`, `"imagesAboveHud"`,
`"fx"`, `"imagesAboveFx"`, `"judgementLine"`, `"imagesAboveJudgementLine"`,
`"bgNotes"`, `"imagesAboveBgNotes"`, `"notes"`, `"imagesAboveNotes"`,
`"circles"`, `"imagesAboveCircles"`, `"tipPoints"`,
`"imagesAboveTipPoints"`, `"fxFront"`, and `"imagesAboveFxFront"`.
The two layers specified by `from` and `to`
and all the layers in between
are affected by the effect event.

Multiple effects that do not affect any common layers can happen at the same time,
but if two effects affect the same layer, only one can happen at a time,
and the later-started one will override the earlier one.
It does not matter whether they have conflicting time-dependent properties,
but all of them are overwritten.

The time-dependent properties `x` and `y` are in the canvas coordinate system.
The time-dependent properties `pivotX` and `pivotY` specify the pivot point,
which is the point around which `rotation` applies the rotation
and also the point whose coordinates are specified by `x` and `y`.
The time-dependent property `rotation` has the positive direction **clockwise**.

## Coordinate system

{% katexmm %}
The coordinate system is a Cartesian coordinate system.
The origin is at the center of the screen.
The positive direction of the $x$-axis is to the right,
and the positive direction of the $y$-axis is to the top,
as in conventions in mathematics.

To give you the sense of how large is a unit length,
the radius of a note (except drag notes, which are smaller) is $12.5$.

It is guaranteed that the area $[-125,125]\times[-75,75]$ is visible
inside the screen
(this is not the case in Lyrica),
but it is recommended to keep all notes inside the area $[-100,100]\times[-50,50]$.

For those events that have `x` and `y` in their `properties`,
the two numbers specify the Cartesian coordinates of the **center** of the event.

The canvas coordinate system is a different coordinate system.
The origin is at the top-left corner of the screen.
The positive direction of the $x$-axis is to the right,
and the positive direction of the $y$-axis is to the bottom.
The unit length of the $x$-axis is the width of the screen,
and the unit length of the $y$-axis is the height of the screen.

Notice that the direction of the $y$-axis is different for the two coordinate systems.
A side effect of this is that the positive direction of rotation is different for the two coordinate systems.
In the chart coordinate system, the positive direction of rotation is counterclockwise,
but in the canvas coordinate system, the positive direction of rotation is clockwise.

Another important difference between the two coordinate systems is that
the chart coordinate system is affected by the player settings `horizontal-flip` and `vertical-flip`
and that the canvas coordinate system is not.
{% endkatexmm %}

## Tip points

Some types of events can have `tipPoint` in their `properties`,
and those events are called **tip-pointable events**,
including `tap`, `hold`, `drag`, `flick`, `placeholder`, and `bgNote`.

Events are connected by one tip point if they have the same `tipPoint` value in their `properties`.
Those events whose `tipPoint` is `null` do not have a tip point connecting them.

A tip point does not have hard limits on how long it exists,
how fast it travels, or how many events it connects.
It can travel at infinite speed
(when connecting two simultaneous events at different positions)
or at zero speed
(when connecting two non-simultaneous events at the same position).

In Lyrica, there is no such notion as `placeholder`,
and `bgNote` is not tip-pointable.
