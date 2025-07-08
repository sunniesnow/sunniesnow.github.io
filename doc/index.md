---
layout: default
title: Level file format specifications
description: The specifications of Sunniesnow level file format
---

# {{ page.title }}
{:.no_toc}

A Sunniesnow level file usually has the extension `.ssc`.

## Table of contents
{:.no_toc}

- toc
{:toc}

## File structure

It is a ZIP file that contains files that are essential to a level.

All file entires in the ZIP file should not be contained in any directory.
At least one [music file](#music-file)
and one [chart file](#chart-file) should be included.
Other optional files includes
[background files](#background-file),
[readme files](#readme-file),
and [storyboard assets](#storyboard-assets).
Other than the storyboard assets,
all the files are in the top level of the ZIP file tree,
and how a file will is purely determined by its filename
(mainly the filename extension).

### Music file

A music file is an audio file.
Whether a file is regarded as a music file is determined by its filename extension.

The following formats of audio are supported:

- WAV,
- MP3,
- OGG Vorbis,
- FLAC,
- Opus,
- QOA.

Although other formats are not supported, their filename extensions are still recognized.

### Chart file

A chart file is a text file that contains the chart data.
It is a JSON file, with the filename extension `.json`.

See [Chart file specifications](chart.html) for more information.

### Background file

A background file is an image file.
Whether a file is regarded as a background file is determined by its filename extension.
The supported formats are determined by the player's browser.
Although other formats are not supported, their filename extensions are still recognized.

### Readme file

The contents of a readme file will be displayed below the game interface.
Any markdown files or plain text files are regarded as readme files.
Other filenames that are recognized as readme files are those that start with (they are all case-insensitive and the underscores in them can be omitted):

- `read_me`,
- `licens`,
- `licenc`,
- `copying`,
- `copyright`,
- `patent`,
- `change_log`,
- `code_of_conduct`,
- `attribution`,
- `version`,
- `contribut`.

Markdown files will be sanitized.
Do not try to be a bad boy!

### Storyboard assets

Storyboard assets are files that are used in the storyboard.
They are located in the `story/` directory in the ZIP file.
Currently, only image files are supported,
and they are used in the [`image`](chart.html#image) events in the charts.

## Mime type

The mime type of a Sunniesnow level file is `application/zip`.
It is also OK to use `application/octet-stream`.
