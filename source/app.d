import std.stdio, std.string;
import std.conv : to;

import derelict.sdl2.sdl, derelict.util.loader : SharedLibVersion;

struct screen_dimensions
{
    int w = 640;
    int h = 480;
};

struct color
{
    ubyte r = 0;
    ubyte g = 0;
    ubyte b = 0;
    ubyte a = 0;
}

static const color red = {255, 0, 0, 255};
static const color blue = {0, 255, 0, 255};
static const color green = {0, 0, 255, 255};

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
            if ((this.renderer = SDL_CreateRenderer(this.window, -1,
                    SDL_RENDERER_ACCELERATED)) == null)
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

bool setup_derelict()
{
    DerelictSDL2.load(SharedLibVersion(2, 0, 2));

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

int main()
{
    //Todo support arguments for screen size

    setup_derelict();

    sdl_window main_window;

    try
    {
        main_window = new sdl_window("flatmap", 640, 480);
    }
    catch (SDLException e)
    {
        writeln("sdl_window failed with: " ~ e.GetError());
    }

    rectangle rect = new rectangle(0, 0, 50, 50, red, main_window.get_renderer());
    rect.centered(main_window.get_size());
    rect.render();

    rectangle rect1 = new rectangle(0, 0, 50, 50, blue, main_window.get_renderer());
    rect1.centered(main_window.get_size());
    rect1.offset(rect.get_rect().w, 'l');
    rect1.render();

    main_window.update();

    SDL_Delay(2000);

    SDL_Quit();

    return 0;
}
