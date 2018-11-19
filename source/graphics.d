import std.random, std.string, std.stdio;
import std.conv : to;
import std.typecons : Tuple, tuple;
import derelict.sdl2.sdl, derelict.sdl2.ttf;
import sdl_funcs : SDL, TTF;

struct screen_dimensions
{
    int w = 640;
    int h = 480;
};

alias color = SDL_Color;

static immutable color red = {255, 0, 0, 255};
static immutable color blue = {0, 255, 0, 255};
static immutable color green = {0, 0, 255, 255};
static immutable color black = {0, 0, 0, 255};

static SDL SDL_;
static TTF TTF_;

shared static this()
{
    SDL_ = new SDL();
    TTF_ = new TTF();
}

static color get_random_color()
{
    auto rnd = new Random(unpredictableSeed);

    color col;

    col.r = cast(ubyte) uniform(0, 255, rnd);
    col.g = cast(ubyte) uniform(0, 255, rnd);
    col.b = cast(ubyte) uniform(0, 255, rnd);
    col.a = cast(ubyte) uniform(0, 255, rnd);

    return col;
}

unittest
{
    for (int i = 0; i < 100; i++)
    {
        color c = get_random_color();

        assert(c.r >= 0);
        assert(c.r <= 255);
        assert(c.g >= 0);
        assert(c.g <= 255);
        assert(c.b >= 0);
        assert(c.b <= 255);
    }

}

class SDLException : Exception
{
    this(string msg, string sdl_error, string file = __FILE__, size_t line = __LINE__)
    {
        this.sdl_error = sdl_error;
        super(msg, file, line);
    }

    string GetError()
    {
        return this.sdl_error;
    }

    private
    {
        string sdl_error;
    }
}

interface renderable_object
{
    public
    {

        @safe pure nothrow void centered(screen_dimensions s);

        @safe pure nothrow void offset(int offset, char alignment);

        void render();
    }
}

class renderable_abstract_object : renderable_object
{
    public
    {
        this(int x, int y, int width, int height, color col, SDL_Renderer* renderer)
        {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
            this.col = col;
            this.renderer = renderer;
        }

        @safe pure nothrow void centered(screen_dimensions s)
        {
            int new_x;
            int new_y;

            new_y = (s.h - this.height) / 2;
            new_x = (s.w - this.width) / 2;

            this.x = new_x;
            this.y = new_y;

            return;
        }

        @safe pure nothrow void offset(int offset, char alignment)
        {
            if (alignment == 'l')
            {
                this.x += offset;
            }
            else if (alignment == 'r')
            {
                this.x -= offset;
            }

            else if (alignment == 't')
            {
                this.y += offset;
            }
            else if (alignment == 'b')
            {
                this.y -= offset;
            }
        }

        void render()
        {
        }
    }

    private
    {
        int x;
        int y;
        int width;
        int height;
        color col;
        SDL_Renderer* renderer;
    }
}

@("Test renderable_abstract_object")
unittest
{
    auto o = new renderable_abstract_object(10, 10, 50, 50, red, null);
    screen_dimensions screen = {200, 200};

    assert(o.x == 10);
    assert(o.y == 10);
    assert(o.width == 50);
    assert(o.height == 50);

    o.centered(screen);

    assert(o.x == 75);
    assert(o.y == 75);

    o.x = 10;
    o.offset(10, 'r');
    assert(o.x == 10 - 10);

    o.x = 10;
    o.offset(10, 'l');
    assert(o.x == 10 + 10);

    o.y = 10;
    o.offset(10, 't');
    assert(o.y == 10 + 10);

    o.y = 10;
    o.offset(10, 'b');
    assert(o.y == 10 - 10);

}

class rectangle : renderable_abstract_object
{
    public
    {
        this(int x, int y, int width, int height, color col, SDL_Renderer* renderer)
        {
            super(x, y, width, height, col, renderer);

            this.create_rect();
        }

        override void render()
        {
            this.rect.x = this.x;
            this.rect.y = this.y;
            this.rect.h = this.height;
            this.rect.w = this.width;

            if ((SDL_.SetRenderDrawColor(this.renderer, this.col.r, this.col.b,
                    this.col.g, this.col.a)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
            if ((SDL_.RenderFillRect(renderer, &this.rect)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
        }

        @safe nothrow SDL_Rect get_rect()
        {
            update_rect();
            return this.rect;
        }

        @safe nothrow immutable(int) get_width()
        {
            update_rect();
            return immutable(int)(this.width);
        }
    }

    private
    {
        void create_rect()
        {
            this.rect.x = this.x;
            this.rect.y = this.y;
            this.rect.w = this.width;
            this.rect.h = this.height;

        }

        @safe nothrow void update_rect()
        {
            this.rect.x = this.x;
            this.rect.y = this.y;
            this.rect.h = this.height;
            this.rect.w = this.width;
        }

        SDL_Rect rect;
    }

}

@("Test rectangle class")
unittest
{
    sdl_window main_window;
    try
    {
        main_window = new sdl_window("flatmap", 640, 480);
    }
    catch (SDLException e)
    {
        writeln("Setting up an SDL window failed with: " ~ e.GetError());
        assert(false);
    }
    catch (Exception e)
    {
        writeln(e.msg);
        assert(false);
    }

    color red = {255, 0, 0, 255};

    rectangle rect = new rectangle(0, 0, 120, 120, red, main_window.get_renderer());

    rect.offset(10, 'l');

    assert(rect.get_rect().x == 0 + 10);

    rect.centered(main_window.get_size());

    assert(rect.get_rect().y == (main_window.get_size().h - 120) / 2);
    assert(rect.get_rect().x == (main_window.get_size().w - 120) / 2);

    rect.render();
}

class line : renderable_abstract_object
{

    public
    {
        this(int x, int y, int x2, int y2, color col, SDL_Renderer* renderer)
        {

            super(x, y, 0, 0, col, renderer);

            this.x2 = x2;
            this.y2 = y2;

        }

        override void render()
        {
            SDL_.SetRenderDrawColor(this.renderer, this.col.r, this.col.g, this.col.b, this.col.a);
            SDL_.RenderDrawLine(this.renderer, this.x, this.y, this.x2, this.y2);
        }
    }

    private
    {
        int x2;
        int y2;
    }

}

class text : renderable_abstract_object
{
    public
    {
        this(string text_content, int x, int y, color col, int fontsize,
                SDL_Renderer* renderer, SDL_Rect* clip = null, double angle = 0.0,
                SDL_Point* center = null, SDL_RendererFlip flip = SDL_FLIP_NONE)
        {

            super(x, y, 0, 0, col, renderer);

            this.clip = clip;
            this.angle = angle;
            this.flip = flip;
            this.font_size = fontsize;

            this.font = TTF_.OpenFont("/usr/share/fonts/TTF/FreeMonoBold.ttf", this.font_size);

            load_rendered_text(text_content);
        }

        ~this()
        {
            SDL_.FreeSurface(this.text_surface);
            SDL_.DestroyTexture(this.texture);
        }

        void load_rendered_text(string text, color text_color = black)
        {
            this.text_surface = TTF_.RenderText_Solid(this.font, toStringz(text), text_color);

            this.texture = SDL_.CreateTextureFromSurface(this.renderer, this.text_surface);

            this.width = text_surface.w;
            this.height = text_surface.h;
        }

        override void render()
        {
            SDL_Rect texture_space = {this.x, this.y, this.width, this.height};

            if (clip)
            {
                texture_space.w = this.clip.w;
                texture_space.h = this.clip.h;
            }

            SDL_.RenderCopyEx(this.renderer, this.texture, this.clip,
                    &texture_space, this.angle, this.center, this.flip);
        }

        @safe pure nothrow immutable(int) get_x()
        {
            return immutable(int)(this.x);
        }

        @safe pure nothrow immutable(int) get_y()
        {
            return immutable(int)(this.y);
        }

        @safe pure nothrow immutable(int) get_width()
        {
            return immutable(int)(this.width);
        }

        @safe pure nothrow immutable(int) get_height()
        {
            return immutable(int)(this.height);
        }
    }

    private
    {
        SDL_Surface* text_surface;
        SDL_Texture* texture;
        SDL_Rect* clip;
        SDL_Point* center;
        SDL_RendererFlip flip = SDL_FLIP_NONE;
        TTF_Font* font;

        int font_size;
        double angle;
    }
}

@("Test text class")
unittest
{

    sdl_window main_window;
    try
    {
        main_window = new sdl_window("flatmap", 640, 480);
    }
    catch (SDLException e)
    {
        writeln("Setting up an SDL window failed with: " ~ e.GetError());
        assert(false);
    }
    catch (Exception e)
    {
        assert(false);
    }

    color red = {255, 0, 0, 255};

    text t = new text("hello", 20, 2, red, 28, main_window.get_renderer());

    t.offset(10, 'r');
    assert(t.get_x() == 20 - 10);

    t.offset(10, 't');
    assert(t.get_y() == 2 + 10);

    t.render();

}

class key
{

    public
    {
        this(screen_dimensions dimensions, SDL_Renderer* renderer,
                bool show_text = true, int fontsize = 16)
        {
            this.font_size = fontsize;
            this.renderer = renderer;
            this.dimensions = dimensions;
            this.show_text = show_text;
        }

        ~this()
        {
            foreach (entry; this.entries)
            {
                destroy(entry.rendered_text);
                destroy(entry.rect);
            }
        }

        void add(color col, string label)
        {
            entries ~= tuple!("color", "label", "rect", "rendered_text", "offset_calculated")(col,
                    label, cast(rectangle) null, cast(text) null, false);
        }

        void remove(string label)
        {
        }

        void render()
        {
            int y_position = 0;

            int longest_label;
            int tallest_label;

            foreach (ref entry; this.entries)
            {
                if (entry.rect is null)
                {
                    entry.rect = this.create_rectangle(entry.color);
                }

                if (entry.rendered_text is null && this.show_text)
                {
                    entry.rendered_text = this.create_text(entry.label);
                }
            }

            if (this.show_text)
            {
                longest_label = this.find_longest_label();
                tallest_label = this.find_tallest_label();
            }

            foreach (ref entry; this.entries)
            {
                if (!entry.offset_calculated)
                {
                    if (this.show_text)
                    {
                        entry.rendered_text.offset(entry.rendered_text.get_width() + this.margin,
                                'r');
                        entry.rendered_text.offset(y_position + tallest_label, 't');
                    }
                    entry.rect.offset(longest_label + entry.rect.get_width() + this.margin, 'r');
                    entry.rect.offset(y_position + tallest_label, 't');

                    entry.offset_calculated = true;
                }

                if (this.show_text)
                {
                    entry.rendered_text.render();
                }
                entry.rect.render();
                y_position += tallest_label + this.margin;
            }
        }

    }

    private
    {
        rectangle create_rectangle(color col)
        {
            return new rectangle(this.dimensions.w, 0, 50, this.font_size, col, this.renderer);
        }

        text create_text(string label)
        {
            return new text(label, dimensions.w, 0, black, this.font_size, this.renderer);
        }

        int find_longest_label()
        {
            int longest_label;

            foreach (entry; this.entries)
            {
                if (entry.rendered_text.get_width() > longest_label)
                {
                    longest_label = entry.rendered_text.get_width();
                }
            }

            return longest_label;
        }

        int find_tallest_label()
        {
            int tallest_label;

            foreach (entry; this.entries)
            {
                if (entry.rendered_text.get_height() > tallest_label)
                {
                    tallest_label = entry.rendered_text.get_height();
                }
            }

            return tallest_label;
        }

        Tuple!(color, "color", string, "label", rectangle, "rect", text,
                "rendered_text", bool, "offset_calculated")[] entries;
        screen_dimensions dimensions;
        SDL_Renderer* renderer;

        bool show_text = true;

        int margin = 5;
        int font_size;
    }
}

class scale
{
    public
    {
        this(int x, int y, int length, int tic_distance, color col, SDL_Renderer* renderer)
        {
            this.x = x;
            this.y = y;
            this.thickness = thickness;
            this.length = length;
            this.col = col;
            this.renderer = renderer;

            create_tics(tic_distance);

            this.xline = new line(this.x, this.y, this.length, this.y, this.col, this.renderer);
        }

        ~this()
        {
            foreach (t; this.tics)
            {
                destroy(t);
            }

            destroy(this.xline);
        }

        void render()
        {

            foreach (tic; this.tics)
            {
                tic.render();
            }

            this.xline.render();
        }

    }
    private
    {

        void create_tics(int tic_distance)
        {
            for (int i = this.x; i < this.length; i += tic_distance)
            {
                this.tics ~= new line(i, this.y, i, this.y - 10, this.col, this.renderer);
            }
        }

        line[] tics;
        line xline;

        int x;
        int y;
        int thickness;
        int length;
        color col;
        SDL_Renderer* renderer;
    }
}

class sdl_window
{

    public
    {
        this()
        {
            this("");
        }

        this(string title, int x = SDL_WINDOWPOS_UNDEFINED, int y = SDL_WINDOWPOS_UNDEFINED,
                immutable(int) width = 640, immutable(int) height = 480,
                immutable(bool) init = true, immutable(bool) has_surface = false)
        {
            this.title = title;
            this.window_x = x;
            this.window_y = y;
            this.window_width = width;
            this.window_height = height;

            this.has_surface = has_surface;

            this.create_window(SDL_WINDOW_SHOWN);

            if (!this.has_surface)
            {
                this.create_renderer();
            }

            this.clear();
        }

        ~this()
        {
            SDL_.DestroyWindow(this.window);
        }

        void update()
        {
            SDL_.RenderPresent(this.renderer);
        }

        void clear()
        {
            SDL_.SetRenderDrawColor(this.renderer, 0xFF, 0xFF, 0xFF, 0xFF);
            SDL_.RenderClear(this.renderer);
        }

        @safe pure nothrow immutable(string) get_title()
        {
            return this.title.dup();
        }

        @safe pure nothrow screen_dimensions get_size()
        {
            screen_dimensions s;
            s.w = this.window_width;
            s.h = this.window_height;
            return s;
        }

        @safe pure nothrow SDL_Window* get_window()
        {
            return this.window;
        }

        @safe pure nothrow SDL_Surface* get_surface()
        {
            return this.surface;
        }

        @safe pure nothrow SDL_Renderer* get_renderer()
        {
            return this.renderer;
        }

    }

    private
    {
        /* \brief Actualy create a window.
         *
         * Throws SDLException on error */
        void create_window(SDL_WindowFlags flags)
        {

            this.window = SDL_.CreateWindow(toStringz(this.title), this.window_x,
                    this.window_y, this.window_width, this.window_height, flags);

            if (this.has_surface)
            {
                this.surface = SDL_.GetWindowSurface(this.window);
            }

        }

        void create_renderer()
        {
            this.renderer = SDL_.CreateRenderer(this.window, -1, SDL_RENDERER_SOFTWARE);
        }

        string title;
        int window_x;
        int window_y;
        int window_width;
        int window_height;
        bool has_surface;
        SDL_Window* window = null;
        SDL_Surface* surface = null;
        SDL_Renderer* renderer = null;
    }
}

unittest
{
    sdl_window main_window;
    try
    {
        main_window = new sdl_window("flatmap", 640, 480);
    }
    catch (SDLException e)
    {
        writeln("Setting up an SDL window failed with: " ~ e.GetError());
        assert(false);
    }
    catch (Exception e)
    {
        assert(false);
    }

    assert(main_window.title == "flatmap");
    assert(main_window.window != null);
    /* assert(main_window.surface != null); */
}
