import std.stdio, std.string, std.getopt, std.file;
import std.typecons : tuple;
import std.conv : to;

import graphics;

template data_point(Tlabel : string, Tstart, Tend)
{

    class data_point
    {
        public
        {
            this(string line, char delimiter)
            {
                string[] splitted = line.split(delimiter);

                writeln(splitted);

                this.label = to!Tlabel(splitted[0].strip());
                this.start = to!Tstart(splitted[1].strip());
                this.end = to!Tend(splitted[2].strip());

            }

            @safe nothrow const Tlabel get_label()
            {
                return this.label;
            }

            @safe nothrow const Tstart get_start()
            {
                return this.start;
            }

            @safe nothrow const Tend get_end()
            {
                return this.end;
            }

        }

        private
        {
            Tlabel label;

            Tstart start;
            Tend end;
        }
    }
}

unittest
{

    data_point!(string, int, int) l = new data_point!(string, int, int)("Hello 10 20", ' ');

    assert(l.get_label() == "Hello");
    assert(l.get_start() == 10);
    assert(l.get_end() == 20);

    l = new data_point!(string, int, int)("Hello 10 20\n", ' ');

    assert(l.get_label() == "Hello");
    assert(l.get_start() == 10);
    assert(l.get_end() == 20);

    l = new data_point!(string, int, int)("Hello 10 20 30\n", ' ');

}

int main(string[] args)
{

    string filename; //The datafile we're opening
    char delimiter = ' '; //The column delimiter
    int blocksize = 1;
    int window_width = 640;
    int window_height = 480;

    File data_file;

    getopt(args, "filename|f", &filename, "delim|d", &delimiter, "blocksize|b",
            &blocksize, "width|w", &window_width, "height|h", &window_height);

    if (exists(filename))
    {
        data_file.open(filename, "r");
    }
    else
    {
        writeln("No input file");
        return 1;
    }

    data_point!(string, int, int)[] data_points;

    foreach (line; data_file.byLine())
    {
        data_points ~= new data_point!(string, int, int)(to!string(line), delimiter);
    }

    //Todo support arguments for screen size

    setup_derelict();

    sdl_window main_window;

    try
    {
        main_window = new sdl_window("flatmap", 0, 0, window_width, window_height);
    }
    catch (SDLException e)
    {
        writeln("sdl_window failed with: " ~ e.GetError());
    }

    rectangle[] rects;

    int total_width;

    foreach (data; data_points)
    {

        writeln("Rect:");
        writeln("x: " ~ 0);
        writeln("y: " ~ 0);
        writeln("width: " ~ to!string(data.get_end()));
        writeln("height: " ~ 50);
        writeln("offset: " ~ to!string(data.get_start()));

        total_width += data.get_end();

        rects ~= new rectangle(0, 0, data.get_end() * blocksize, 50,
                get_random_color(), main_window.get_renderer());
        //rects[rects.length-1].centered(main_window.get_size());
        rects[rects.length - 1].offset(data.get_start() * blocksize, 'l');
        rects[rects.length - 1].render();
    }

    main_window.update();

    Delay(5000);

    Quit();

    return 0;
}
