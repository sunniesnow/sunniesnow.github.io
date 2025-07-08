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

- **Type**: non-empty string.

The title of the music.

### `artist`

- **Type**: non-empty string.

The artist of the music.

### `charter`

- **Type**: non-empty string.

The charter of the chart.

### `difficultyName`

- **Type**: non-empty string.

The name of the difficulty.
In Lyrica equivalents, possible values are
`"Easy"`, `"Normal"`, `"Hard"`, `"Master"`, and `"Special"`.
However, you are free to use other names.

### `difficultyColor`

- **Type**: color source.

The color of the difficulty.

A color source may be a string of
[`<color>` CSS data type](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value),
or it may be an integer whose hexadecimal representation is the color.

### `difficulty`

- **Type**: non-empty string.

The difficulty of the chart.
In Lyrica equivalents, possible values are decimal representations
of any integers from 1 to 13.
However, you are free to use other values.

### `difficultySup`

- **Type**: string.
- **Default**: `""`.

A superscript shown near the difficulty.
Usually either an empty string or `"+"`.

### `offset`

- **Type**: float number.
- **Default**: `0.0`.

The offset of the chart, in seconds.
**Usually, this should be zero.**
This is only used by chart reviewers to adjust the offset after the chart is already made.
Chart makers should generally avoid using this and leave it as zero.

### `sscharter`

- **Type**: `null`, or an object with properties: `version` a string, and `port` an integer.
- **Default**: `null`.

Used for sscharter integration.

### `events`

- **Type**: non-empty array of event objects.

The events of the chart.
To see how an event object is structured,
see [Event object](#event-object).

## Event object

An event object is an object with the required keys `type`, `time`, and `properties`,
and optional keys `timeDependent`.
Missing a required key will trigger a warning, and this event object will be ignored.

### `type`

- **Type**: string (with a limited set of possible values).

Here is a list of possible values:

- [`"tap"`](#tap),
- [`"hold"`](#hold),
- [`"drag"`](#drag),
- [`"flick"`](#flick),
- [`"placeholder"`](#placeholder),
- [`"bgNote"`](#background-note),
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

See [Event types](#event-types) for more information.

### `time`

- **Type**: float number.

This specifies the time of the event, in seconds,
measured from the start of the music.

It may be negative or greater than the duration of the music,
but take note that these events may not be actually included in the chart
unless the player specifies [start and end](/game/help.html#start-and-end) to a larger range.

### `properties`

- **Type**: object.

The structure of this object depends on the value of `type`.
Some of the entries of this object are required, while others are optional.
If required entries are missing, a warning will be triggered,
and this event object will be ignored.
If there are unknown entries, a warning will be triggered.
See [Event types](#event-types) for more information.

### `timeDependent`

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

Some of the supported keys are shared by multiple types of events.
To avoid verbosity, they are documented here,
and will not be explained again in the event types.

### `x`, `y`

They are used to change the spatial coordinates of the event
so that it can appear moving.
They share the same coordinate system as the `x` and `y` in `properties`
(see [Coordinate system](#coordinate-system) for more information).
Note that anything in `timeDependent` will not affect the judgement of the event,
so even if the `x` and `y` values change over time,
the judgement position is still the position specified by `x` and `y` in `properties`.

### `circle`

It is used to control the radius of the shrinking circle.
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

### `opacity`

It is used to control the opacity of the event.
When the value is `0.0`, the event is completely transparent,
and when the value is `1.0`, the event is completely opaque.

### `size`

It is used to control the visual size of the event.
When the value is `0.0`, the event is not shown at all,
and when the value is `1.0`, the event is at its normal size.

### `rotation`

It is used to control the rotation of the event.
It is in radians, and the positive direction is counterclockwise.

### `text`

It is used to control the text displayed on the event.

## Event types

The following sections describe each different [`type`](#type) of event,
including how their [`properties`](#properties) are structured.

### Tap

- **`type`**: `"tap"`.
- **`properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).
  - **`size` (optional)**: float number (default: `1.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`circle`**: number (default `value`: `0.0`; default `speed`: `1.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).
  - **`text`**: string.

A `tap` event is a tap note.
Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

If `tipPoint` is not `null`,
then the tap note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `text` specifies the text displayed on the tap note.

The property `size` scales the size of the judgement area.

### Hold

- **`type`**: `"hold"`.
- **`properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`duration`**: positive float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).
  - **`size` (optional)**: float number (default: `1.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`circle`**: number (default `value`: `0.0`; default `speed`: `1.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).
  - **`text`**: string.

A `hold` event is a hold note.
Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

The property `duration` specifies the duration of the hold note, in seconds.

If `tipPoint` is not `null`,
then the hold note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `text` specifies the text displayed on the hold note.

The property `size` scales the size of the judgement area.

### Drag

- **`type`**: `"drag"`.
- **`properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`size` (optional)**: float number (default: `1.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`circle`**: number (default `value`: `0.0`; default `speed`: `1.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

A `drag` event is a drag note.
Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

If `tipPoint` is not `null`,
then the drag note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `size` scales the size of the judgement area.

### Flick

- **`type`**: `"flick"`.
- **`properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`angle`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).
  - **`size` (optional)**: float number (default: `1.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`circle`**: number (default `value`: `0.0`; default `speed`: `1.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).
  - **`text`**: string.

A `flick` event is a flick note.
Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

The property `angle` specifies the angle of the flick note, in **radians**.
Zero angle is to the right, and increasing angle is counterclockwise
(as in conventions of mathematics about polar coordinates).

If `tipPoint` is not `null`,
then the flick note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `text` specifies the text displayed on the flick note.

The property `size` scales the size of the judgement area.

### Placeholder

- **`type`**: `"placeholder"`.
- **`properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
- **`timeDependent`**: none.

A `placeholder` event basically does nothing,
but it can have a tip point by specifying `tipPoint`.
See [Tip points](#tip-points) for more information.

### Background note

- **`type`**: `"bgNote"`.
- **`properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).
  - **`size` (optional)**: float number (default: `1.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`circle`**: number (default `value`: `0.0`; default `speed`: `1.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).
  - **`text`**: string.

A `bgNote` event is a background note (often called an "ink" by Lyrica players).

Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

The property `duration` specifies the duration of the background note, in seconds.

If `tipPoint` is not `null`,
then the background note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `text` specifies the text displayed on the background note.

The property `size` does nothing
(but it may be useful because it is the default `value` of the `size` option
in `timeDependent`).

### Big text

- **`type`**: `"bigText"`.
- **`properties`**:
  - **`text`**: string.
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).
  - **`text`**: string.

A `bigText` event is a big text.
It is one kind of background patterns
that are displayed in the center of the screen.

The property `text` specifies the text displayed on the big text.

The property `duration` specifies the duration of the big text, in seconds.

### Grid

- **`type`**: `"grid"`.
- **`properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

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

The property `duration` specifies the duration of the grid, in seconds.

### Hexagon

- **`type`**: `"hexagon"`.
- **`properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

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

### Checkerboard

- **`type`**: `"checkerboard"`.
- **`properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

A `checkerboard` event is a checkerboard.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The checkerboard has $4$ rows of cells and $4$ columns of cells.
The top-left cell has its center at $(-37.5,37.5)$.
The bottom-right cell has its center at $(37.5,-37.5)$.
The side length of each cell is $25$.
{% endkatexmm %}

### Diamond grid

- **`type`**: `"diamondGrid"`.
- **`properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

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

### Pentagon

- **`type`**: `"pentagon"`.
- **`properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

A `pentagon` event is a pentagon.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The vertices of the pentagon are
$(50\cos(\pi/2+2k\pi/5),50\sin(\pi/2+2k\pi/5))$,
where $k=0,1,2,3,4$.
If you need more explicit expressions, they are
$$(0,50),\quad
\left(\pm25\sqrt{\frac{5+\sqrt5}2},25\frac{\sqrt5-1}2\right),\quad
\left(\pm25\sqrt{\frac{5-\sqrt5}2},25\frac{\sqrt5+1}2\right).$$
{% endkatexmm %}

### Turntable

- **`type`**: `"turntable"`.
- **`properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

A `turntable` event is a turntable.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The turntable has two circles concentric at $(0,0)$.
Their radii are respectively $25$ and $50$.
{% endkatexmm %}

### Hexagram

- **`type`**: `"hexagram"`.
- **`properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`size`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

A `hexagram` event is a hexagram.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The turntable consists of two triangles whose centers are both $(0,0)$
and radii are both $50$ (side lengths $25\sqrt3$).
One of the triangles is upright, and the other is upside-down.
{% endkatexmm %}

### Image

- **`type`**: `"image"`.
- **`properties`**:
  - **`filename`**: non-empty string.
  - **`x`**: float number.
  - **`y`**: float number.
  - **`width`**: float number.
  - **`height` (optional)**: float number.
  - **`duration`**: non-negative float number.
- **`timeDependent`**:
  - **`x`**: number (default `speed`: `0.0`).
  - **`y`**: number (default `speed`: `0.0`).
  - **`z`**: uninterpolable number (default `value`: `0.0`).
  - **`opacity`**: number (default `value`: `1.0`; default `speed`: `0.0`).
  - **`width`**: number (default `speed`: `0.0`).
  - **`height`**: uninterpolable number (default `speed`: `0.0`).
  - **`anchorX`**: uninterpolable number (default `value`: `0.5`).
  - **`anchorY`**: uninterpolable number (default `value`: `0.5`).
  - **`rotation`**: number (default `value`: `0.0`; default `speed`: `0.0`).

Displaying an image.
The image is shown below all the notes, background notes, and hit effects,
but above all the background patterns.

The properties `x` and `y` specify the coordinates of the image.
The property `width` and `height` specify the size of the image.
If `height` is omitted, it is set to keep the original aspect ratio of the image.
The property `filename` specifies the filename of the image
inside `story/` directory in the level file
(special path components like `.` and `..` are not allowed).
The property `duration` specifies the duration of the image, in seconds.

In the time-dependent properties,
the property `z` specifies the z-index of the image,
which controls the whether an image is displayed above or below other images.
Images with larger `z` values are displayed above images with smaller `z` values.
The properties `anchorX` and `anchorY` specify the anchor point of the image,
which is the point that the image rotates around
and the point whose coordinates are specified by `x` and `y`.
The default values of `anchorX` and `anchorY` are both `0.5`,
which means the anchor point is at the center of the image.
If they are both `0.0`, the anchor point is at the top-left corner of the image.

### Global speed

- **`type`**: `"globalSpeed"`.
- **`properties`**:
  - **`speed`**: float number.
- **`timeDependent`**: none.

Controls the global speed (of shrinking circles).
You can set it to zero or negative values.

Technically, you can use the time-dependent `circle` property
in the notes to achieve any effects that this event can achieve,
but this event is provided to reduce file sizes of chart files.

## Coordinate system

{% katexmm %}
The coordinate system is a Cartesian coordinate system.
The origin is at the center of the screen.
The positive direction of the $x$-axis is to the right,
and the positive direction of the $y$-axis is to the top,
as in conventions in mathematics.

To give you the sense of how large is a unit length,
the radius of a note (except drag notes, which are smaller) is $12.5$.

It is guaranteed that the area $[-137.5,137.5]\times[-75,75]$ is visible
inside the screen
(this is not the case in Lyrica),
but it is recommended to keep all notes inside the area $[-100,100]\times[-50,50]$.

For those events that have `x` and `y` in their `properties`,
the two numbers specify the Cartesian coordinates of the **center** of the event.
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
