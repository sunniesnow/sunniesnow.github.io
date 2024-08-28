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
All of them are required,
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

An event object is an object with the following keys.
All of them are required.
Missing values will trigger a warning, and this event object will be ignored.

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
- [`"hexagram"`](#hexagram).

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

## Event types

The following sections describe each different [`type`](#type) of event,
including how their [`properties`](#properties) are structured.

### Tap

- **`type`**: `"tap"`.
- **Types of entries of `properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).

A `tap` event is a tap note.
Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

If `tipPoint` is not `null`,
then the tap note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `text` specifies the text displayed on the tap note.

### Hold

- **`type`**: `"hold"`.
- **Types of entries of `properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`duration`**: positive float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).

A `hold` event is a hold note.
Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

The property `duration` specifies the duration of the hold note, in seconds.

If `tipPoint` is not `null`,
then the hold note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `text` specifies the text displayed on the hold note.

### Drag

- **`type`**: `"drag"`.
- **Types of entries of `properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).

A `drag` event is a drag note.
Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

If `tipPoint` is not `null`,
then the drag note will have a tip point.
See [Tip points](#tip-points) for more information.

### Flick

- **`type`**: `"flick"`.
- **Types of entries of `properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`angle`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).

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

### Placeholder

- **`type`**: `"placeholder"`.
- **Types of entries of `properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`tipPoint` (optional)**: nullable string (default: `null`).

A `placeholder` event basically does nothing,
but it can have a tip point by specifying `tipPoint`.
See [Tip points](#tip-points) for more information.

### Background note

- **`type`**: `"bgNote"`.
- **Types of entries of `properties`**:
  - **`x`**: float number.
  - **`y`**: float number.
  - **`duration` (optional)**: non-negative float number (default: `0.0`).
  - **`tipPoint` (optional)**: nullable string (default: `null`).
  - **`text` (optional)**: string (default: `""`).

A `bgNote` event is a background note (often called a "ink" by Lyrica players).

Its coordinates are specified by `x` and `y`
(see [Coordinate system](#coordinate-system) for more information).

The property `duration` specifies the duration of the background note, in seconds.

If `tipPoint` is not `null`,
then the background note will have a tip point.
See [Tip points](#tip-points) for more information.

The property `text` specifies the text displayed on the background note.

### Big text

- **`type`**: `"bigText"`.
- **Types of entries of `properties`**:
  - **`text`**: string.
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

A `bigText` event is a big text.
It is one kind of background patterns
that are displayed in the center of the screen.

The property `text` specifies the text displayed on the big text.

The property `duration` specifies the duration of the big text, in seconds.

### Grid

- **`type`**: `"grid"`.
- **Types of entries of `properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

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
- **Types of entries of `properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

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
- **Types of entries of `properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

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
- **Types of entries of `properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

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
- **Types of entries of `properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

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
- **Types of entries of `properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

A `turntable` event is a turntable.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The turntable has two circles concentric at $(0,0)$.
Their radii are respectively $25$ and $50$.
{% endkatexmm %}

### Hexagram

- **`type`**: `"hexagram"`.
- **Types of entries of `properties`**:
  - **`duration` (optional)**: non-negative float number (default: `0.0`).

A `hexagram` event is a hexagram.
It is one kind of background patterns
that are displayed in the center of the screen.

{% katexmm %}
The turntable consists of two triangles whose centers are both $(0,0)$
and radii are both $50$ (side lengths $25\sqrt3$).
One of the triangles is upright, and the other is upside-down.
{% endkatexmm %}

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
