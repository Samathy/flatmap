flatmap
--------------------------

Flatmap is a graphical tool for displaying things like memory mappings, protocol headers and data structures.

Flatmap is written in D and can be built with dub.

    dub build

It depends on SDL2 and SDL TTF.

An example file is included as 'tcp.dat'. It is structured with with fields:
Label | Offset | Block Count.

It produces the image: ![Flatmap TCP example](flatmap_TCP.png)

Flatmap can be ran as such:

    flatmap -f <filename> -d '<delimiting character>' -b <block size (default 1)> -w <display width (default 640)> -h <display height (default 480)>

All options apart from filename are optional.

##### A note on blocksize and multiplier.

One can combine the blocksize and multiplier flags to display the graph in the easiest way.
The blocksize (defaulting to 1) is multiplied by the 'block count' field of the data file.

e.g Given a datapoint with an offset of 0 and a block count of 1, with a block
    size of 10 will result in a 10(bit) block displayed.  The scale will show 0
    -> 10 and fill a rectangle between 0 and 10, since it is 10(bits) large, or 1 block (of 10).
    Given a datapoint with an offset of 0 and a block count of 10 with block
    size of 1 will show a scale from 0, to 1, but visually, the size of the
    displayed rectangle will be the same as the first example, however, the
    scale will include tics at intervals of 1. The data is interpreted as 10 blocks of 1.

In essence, the block size parameter exists to display the correct values on
the scale, and interpret the block count data values correctly.

Using the multiplier parameter one can maintain a scale reading in block sizes,
but increase and decrease the size of displayed blocks, possibly making it
easier to display data with particularly large, or small block sizes.

e.g Given a block count of 1 and a block size of 1 with a multiplier of 1 the
    scale displays a block from 0 -> 1, however, the size of the displayed block is
    uselessly small.
    Increasing the multiplier to 100 increases the visual size of the block by 100,
    but maintains a scale reading 0 -> 1.
    Negative multipliers do not work at this time. It is suggested that you
    re-organise your data's block sizes.

### TODO list

- [x] Move the SDL functions to their own classes/module 
   - [ ] Work out how to properly unittest the classes which use SDL functions.
- [x] Add a scale (which changes depending on block size) to bottom of graph
- [ ] Add ddoc documentation comments
- [ ] Implement proper unittesting with d-unit
- [x] Implement some nice way of closing the window
- [x] Support scrolling display
- [ ] Support piping in values on stdin
    - [ ] Support continuous updating from stdin values
- [x] Support multiple graphs on the same screen
- [x] Support saving image
- [x] Support specifying block sizes
- [x] Support adding labels
- [x] Support a key
- [x] Display key below graphs
- [ ] Add option to display key horizontally.
- [ ] Move the drawing to make sure it stays centered
- [ ] zoom support
- [ ] Get rid of the numerous constant 'magic numbers'
