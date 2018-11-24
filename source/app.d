import std.stdio, std.string, std.getopt, std.file, core.thread;
import std.typecons : tuple;
import std.conv : to;

import graphics;
import derelict.sdl2.sdl;

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

    string[] filename; //The datafile we're opening
    char delimiter = ' '; //The column delimiter
    int blocksize = 1;
    int multiplier = 1;
    int window_width = 640;
    int window_height = 480;
    int total_width;
    bool quit = false;
    SDL_Event e;
    File data_file;
    data_point!(string, int, int)[][] graphs;

    getopt(args, "filename|f", &filename, "delim|d", &delimiter, "blocksize|b", &blocksize,
            "multiplier|m", &multiplier, "width|w", &window_width, "height|h", &window_height);

    foreach (input_file; filename)
    {

        if (exists(input_file))
        {
            data_file.open(input_file, "r");
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

        graphs ~= data_points;
    }

    //Todo support arguments for screen size

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
    key graph_key;
    scale graph_scale;
    int vertical_offset = 5;

    graph_key = new key(main_window.get_size(), main_window.get_renderer(), true);

    foreach (graph; graphs)
    {
        foreach (data; graph)
        {
            color rect_color = get_random_color();

            rects ~= new rectangle(0, 0, data.get_end() * blocksize * multiplier,
                    50, rect_color, main_window.get_renderer());
            //rects[rects.length-1].centered(main_window.get_size());
            rects[$ - 1].offset(data.get_start() * blocksize * multiplier, 'l');
            rects[$ - 1].offset(vertical_offset, 't');
            rects[$ - 1].render();
            graph_key.add(rect_color, data.get_label());

            total_width += rects[$ - 1].get_width();

        }
        vertical_offset += 50;
    }

    graph_key.offset(vertical_offset + 20, 't');

    if (blocksize >= 15 || multiplier >= 15 || blocksize + multiplier >= 15)
        graph_scale = new scale(0, 20 + vertical_offset, total_width, blocksize,
                multiplier, true, red, main_window.get_renderer());
    else
        graph_scale = new scale(0, 20 + vertical_offset, main_window.get_size()
                .w, blocksize, multiplier, false, red, main_window.get_renderer());

    graph_key.render();
    graph_scale.render();

    //We should probably prevent scrolling the graph off the screen, at some point.
    auto update_rect_locations = delegate void(int value, char alignment) {
        foreach (rect; rects)
        {
            rect.offset(value, alignment);
        }
    };

    auto render_rects = delegate void() {
        foreach (rect; rects)
        {
            rect.render();
        }
    };

    auto save_surface = delegate void() {
        SDL_.SaveBMP(SDL_.GetWindowSurface(main_window.get_window()), "flatmap_save.bmp");
    };

    while (!quit)
    {

        while (SDL_PollEvent(&e) != 0)
        {
            if (e.type == SDL_QUIT)
            {
                quit = true;
            }
            else if (e.type == SDL_KEYDOWN)
            {
                switch (e.key.keysym.sym)
                {
                case SDLK_RIGHT:
                    update_rect_locations(10, 'r');
                    graph_scale.offset(10, 'r');
                    break;
                case SDLK_LEFT:
                    update_rect_locations(10, 'l');
                    graph_scale.offset(10, 'l');
                    break;
                case SDLK_s:
                    save_surface();
                    break;
                case SDLK_q:
                    quit = true;
                    break;
                default:
                    break;
                }
            }
        }

        main_window.clear();

        graph_key.render();
        graph_scale.render();
        render_rects();

        main_window.update();
        Thread.sleep(dur!("msecs")(2));
    }

    /* We have to call destroy on all our SDL-using objects before SDL gets
     * quitted. Because the destructors don't get called in a consistent order and calling
     * some free-ing SDL functions (FreeSurface ect) after SDL_Quit() is called will cause segfaults.
     * 
     * Just calling SDL_Quit and expecting it to clean up our memory is probably okay. But we should be clean.
     * There is probably some cleverer way of doing this.
     */
    destroy(graph_key);
    destroy(graph_scale);

    foreach (rect; rects)
    {
        destroy(rect);
    }

    destroy(main_window);

    return 0;
}
