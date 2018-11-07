import std.random, std.string, std.stdio;
import std.conv : to;
import std.typecons : Tuple, tuple;
import derelict.sdl2.sdl, derelict.sdl2.ttf, derelict.util.loader : SharedLibVersion;

struct screen_dimensions
{
    int w = 640;
    int h = 480;
};

alias color = SDL_Color;

static const color red = {255, 0, 0, 255};
static const color blue = {0, 255, 0, 255};
static const color green = {0, 0, 255, 255};
static const color black = {0, 0, 0, 255};

static const color[] colors = [red, green, blue, {255, 0, 255, 255}, {
    100, 100, 0, 255
}, {100, 200, 50, 255}, {72, 214, 176, 255}, {
    2, 252, 233, 255
}, {240, 229, 58, 255}, {192, 126, 57, 255}, {
    168, 108, 37, 255
}, {187, 223, 113, 255}, {69, 213, 176, 255}, {
    236, 173, 64, 255
}, {221, 32, 217, 255}, {204, 75, 102, 255}, {
    187, 236, 70, 255
}, {165, 58, 221, 255}, {239, 124, 193, 255}, {
    236, 84, 83, 255
}, {225, 208, 128, 255}, {186, 189, 164, 255}, {
    229, 84, 127, 255
}, {87, 173, 45, 255}, {75, 30, 167, 255}, {
    12, 203, 130, 255
}, {31, 71, 155, 255}, {58, 247, 95, 255}, {
    94, 98, 171, 255
}, {207, 177, 251, 255}, {175, 51, 230, 255}, {
    167, 180, 146, 255
}, {106, 125, 180, 255}, {20, 144, 193, 255}, {
    171, 29, 224, 255
}, {59, 252, 184, 255}, {149, 93, 181, 255}, {
    196, 255, 116, 255
}, {77, 154, 152, 255}, {116, 250, 247, 255}, {
    106, 188, 247, 255
}, {57, 144, 15, 255}, {85, 146, 124, 255}, {
    29, 192, 200, 255
}, {211, 225, 124, 255}, {90, 231, 169, 255}, {
    63, 8, 182, 255
}, {229, 194, 51, 255}, {240, 126, 82, 255}, {
    225, 221, 194, 255
}, {48, 127, 227, 255}, {236, 66, 145, 255}, {
    203, 187, 240, 255
}, {187, 50, 208, 255}, {167, 146, 112, 255}, {
    192, 152, 179, 255
}, {84, 153, 196, 255}, {148, 216, 80, 255}, {
    39, 66, 17, 255
}, {53, 67, 111, 255}, {57, 227, 183, 255}, {
    194, 167, 67, 255
}, {4, 113, 14, 255}, {213, 247, 185, 255}, {
    243, 9, 243, 255
}, {201, 115, 253, 255}, {29, 238, 128, 255}, {
    54, 84, 184, 255
}, {183, 221, 198, 255}, {51, 113, 239, 255}, {
    212, 61, 141, 255
}, {102, 85, 17, 255}, {83, 69, 133, 255}, {
    200, 238, 149, 255
}, {93, 234, 102, 255}, {98, 82, 30, 255}, {
    211, 213, 64, 255
}, {39, 219, 75, 255}, {80, 31, 63, 255}, {7, 162, 88, 255}, {
    154, 145, 180, 255
}, {134, 188, 57, 255}, {52, 185, 212, 255}, {
    96, 151, 42, 255
}, {147, 106, 56, 255}, {41, 135, 224, 255}, {
    130, 80, 58, 255
}, {232, 248, 176, 255}, {208, 158, 208, 255}, {
    239, 27, 237, 255
}, {223, 125, 169, 255}, {102, 2, 45, 255}, {
    39, 170, 11, 255
}, {191, 67, 4, 255}, {170, 113, 130, 255}, {13, 243, 0, 255}, {
    209, 150, 102, 255
}, {121, 204, 156, 255}, {2, 10, 204, 255}, {
    248, 149, 31, 255
}, {196, 245, 60, 255}, {131, 60, 147, 255}, {
    179, 187, 232, 255
}, {77, 9, 198, 255}, {130, 111, 143, 255}, {
    4, 227, 171, 255
}];

color get_random_color()
{
    auto rnd = new Random(unpredictableSeed);
    return colors[uniform(0, colors.length - 1, rnd)];
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

bool setup_derelict()
{
    DerelictSDL2.load(SharedLibVersion(2, 0, 2));

    DerelictSDL2ttf.load();

    return true;
}

unittest
{
    try
    {
        assert(setup_derelict() == true);
    }

    catch (SDLException e)
    {
        assert(false, "setup_derelict threw: " ~ e.GetError());
    }
    catch (Exception e)
    {
        assert(false);
    }
}

void Delay(int secs)
{
    SDL_Delay(secs);
}

void Quit()
{
    TTF_Quit();
    SDL_Quit();
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

class rectangle
{
    public
    {
        this(int x, int y, int width, int height, color col, SDL_Renderer* renderer)
        {

            this.rect_x = x;
            this.rect_y = y;
            this.rect_width = width;
            this.rect_height = height;
            this.col = col;

            this.renderer = renderer;

            this.create_rect();
        }

        @safe pure nothrow void centered(screen_dimensions s)
        {
            int new_x;
            int new_y;

            new_y = (s.h - this.rect_height) / 2;
            new_x = (s.w - this.rect_width) / 2;

            this.rect_x = new_x;
            this.rect_y = new_y;
            this.rect.x = new_x;
            this.rect.y = new_y;

            return;
        }

        @safe pure nothrow void offset(int offset, char alignment)
        {
            if (alignment == 'l')
            {
                this.rect.x += offset;
            }
            else if (alignment == 'r')
            {
                this.rect.x -= offset;
            }

            else if (alignment == 't')
            {
                this.rect.y += offset;
            }
            else if (alignment == 'b')
            {
                this.rect.y -= offset;
            }
        }

        void render()
        {
            if ((SDL_SetRenderDrawColor(this.renderer, this.col.r, this.col.b,
                    this.col.g, this.col.a)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
            if ((SDL_RenderFillRect(renderer, &this.rect)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
        }

        @safe pure nothrow const SDL_Rect get_rect()
        {
            return this.rect;
        }

        @safe pure nothrow const int get_width()
        {
            return this.rect_width;
        }
    }

    private
    {
        void create_rect()
        {
            this.rect.x = this.rect_x;
            this.rect.y = this.rect_y;
            this.rect.w = this.rect_width;
            this.rect.h = this.rect_height;

        }

        SDL_Rect rect;
        SDL_Renderer* renderer;
        color col;

        int rect_x;
        int rect_y;
        int rect_width;
        int rect_height;
    }

}

unittest
{

    setup_derelict();
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

    rectangle rect = new rectangle(0, 0, 120, 120, red, main_window.get_renderer());

    rect.offset(10, 'l');

    assert(rect.get_rect().x == 0 + 10);

    rect.centered(main_window.get_size());

    assert(rect.get_rect().y == (main_window.get_size().h - 120) / 2);
    assert(rect.get_rect().x == (main_window.get_size().w - 120) / 2);

    rect.render();

}

class text
{
    public
    {
        this(string text_content, int x, int y, color col, int fontsize,
                SDL_Renderer* renderer, SDL_Rect* clip = null, double angle = 0.0,
                SDL_Point* center = null, SDL_RendererFlip flip = SDL_FLIP_NONE)
        {
            this.renderer = renderer;
            this.x = x;
            this.y = y;
            this.clip = clip;
            this.angle = angle;
            this.flip = flip;
            this.text_color = col;
            this.font_size = fontsize;

            if ((TTF_Init()) < 0)
            {
                throw new SDLException("Could not initialise SDLTTF Library",
                        to!string(TTF_GetError()));
            }

            if ((this.font = TTF_OpenFont("/usr/share/fonts/TTF/FreeMonoBold.ttf",
                    this.font_size)) == null)
            {
                throw new SDLException("Could not load font", to!string(TTF_GetError()));
            }

            load_rendered_text(text_content);

        }

        ~this()
        {
            SDL_FreeSurface(text_surface);
            SDL_DestroyTexture(this.texture);
        }

        void load_rendered_text(string text, color text_color = black)
        {
            if ((this.text_surface = TTF_RenderText_Solid(this.font,
                    toStringz(text), text_color)) == null)
            {
                throw new SDLException("Could not create text surface", to!string(SDL_GetError()));
            }

            if ((this.texture = SDL_CreateTextureFromSurface(this.renderer,
                    this.text_surface)) == null)
            {
                throw new SDLException("Could not create text texture", to!string(SDL_GetError()));
            }

            this.width = text_surface.w;
            this.height = text_surface.h;
        }

        void render()
        {
            SDL_Rect texture_space = {this.x, this.y, this.width, this.height};

            if (clip)
            {
                texture_space.w = this.clip.w;
                texture_space.h = this.clip.h;
            }

            SDL_RenderCopyEx(this.renderer, this.texture, this.clip,
                    &texture_space, this.angle, this.center, this.flip);
        }

        void offset(int offset, char alignment)
        {
            if (alignment == 'r')
            {
                this.x -= offset;
            }
            else if (alignment == 't')
            {
                this.y += offset;
            }
            else
            {
                throw new Exception("E_NOTIMPL");
            }
        }

        @safe pure nothrow const int get_x()
        {
            return this.x;
        }

        @safe pure nothrow const int get_y()
        {
            return this.y;
        }

        @safe pure nothrow const int get_width()
        {
            return this.width;
        }

        @safe pure nothrow const int get_height()
        {
            return this.height;
        }
    }

    private
    {
        SDL_Surface* text_surface;
        SDL_Renderer* renderer;
        SDL_Texture* texture;
        SDL_Rect* clip;
        SDL_Point* center;
        SDL_RendererFlip flip = SDL_FLIP_NONE;
        TTF_Font* font;

        color text_color;

        int font_size;
        double angle;
        int width;
        int height;
        int x;
        int y;
    }
}

unittest
{

    setup_derelict();
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

    text t = new text("hello", 20, 2, red, main_window.get_renderer());

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
        this(screen_dimensions dimensions, SDL_Renderer* renderer, int fontsize = 16)
        {
            this.font_size = fontsize;
            this.renderer = renderer;
            this.dimensions = dimensions;
        }

        void add(color col, string label)
        {
            entries ~= tuple!("color", "label", "rect", "rendered_text")(col,
                    label, cast(rectangle) null, cast(text) null);
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

                if (entry.rendered_text is null)
                {
                    entry.rendered_text = this.create_text(entry.label);
                }
            }

            longest_label = this.find_longest_label();
            tallest_label = this.find_tallest_label();

            foreach (ref entry; this.entries)
            {
                if (entry.rect is null || entry.rendered_text is null)
                {
                    throw new Exception("Whoops, entries are null");
                }

                entry.rendered_text.offset(entry.rendered_text.get_width() + this.margin, 'r');
                entry.rendered_text.offset(y_position + tallest_label, 't');
                entry.rect.offset(longest_label + entry.rect.get_width() + this.margin, 'r');
                entry.rect.offset(y_position + tallest_label, 't');

                entry.rendered_text.render();
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

        Tuple!(color, "color", string, "label", rectangle, "rect", text, "rendered_text")[] entries;
        screen_dimensions dimensions;
        SDL_Renderer* renderer;

        int margin = 5;
        int font_size;
    }
}

class sdl_window
{

    public
    {
        this(string title, int x = SDL_WINDOWPOS_UNDEFINED, int y = SDL_WINDOWPOS_UNDEFINED,
                const int width = 640, const int height = 480,
                const bool init = true, const bool has_surface = false)
        {
            this.title = title;
            this.window_x = x;
            this.window_y = y;
            this.window_width = width;
            this.window_height = height;

            this.has_surface = has_surface;

            if (init)
            {
                if (SDL_Init(SDL_INIT_VIDEO) > 0)
                {
                    throw new SDLException("Failed to initialise SDL", to!string(SDL_GetError()));
                }
            }

            this.create_window(SDL_WINDOW_SHOWN);

            if (!this.has_surface)
            {
                this.create_renderer();
            }

            this.clear();
        }

        ~this()
        {
            SDL_DestroyWindow(this.window);
        }

        void update()
        {
            SDL_RenderPresent(this.renderer);
        }

        void clear()
        {
            SDL_SetRenderDrawColor(this.renderer, 0xFF, 0xFF, 0xFF, 0xFF);
            SDL_RenderClear(this.renderer);
        }

        // I'd like to make these return const-only pointers. but idk how to do that.
        @safe pure nothrow string get_title()
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

            if ((this.window = SDL_CreateWindow(toStringz(this.title), this.window_x,
                    this.window_y, this.window_width, this.window_height, flags)) == null)
            {
                throw new SDLException("Failed to create SDL window" ~ this.title,
                        to!string(SDL_GetError()));
            }

            if (this.has_surface)
            {
                if ((this.surface = SDL_GetWindowSurface(this.window)) == null)
                {
                    throw new SDLException("Failed to get window surface.",
                            to!string(SDL_GetError()));
                }
            }

        }

        void create_renderer()
        {
            if ((this.renderer = SDL_CreateRenderer(this.window, -1, SDL_RENDERER_SOFTWARE)) == null)
            {
                throw new SDLException("Failed to create renderer.", to!string(SDL_GetError()));
            }
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

    setup_derelict();
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
