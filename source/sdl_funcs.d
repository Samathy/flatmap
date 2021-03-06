import std.conv : to;
import std.stdio, std.string;

import derelict.sdl2.sdl, derelict.sdl2.ttf, derelict.util.exception,
    derelict.util.loader : SharedLibVersion;

///Module constructor to load SDL libs.
shared static this()
{

    try
    {
        DerelictSDL2.load(SharedLibVersion(2, 0, 2));
    }
    catch (SharedLibLoadException e)
    {
        throw new Error(e.msg);
    }

    try
    {
        DerelictSDL2ttf.load();
    }
    catch (SharedLibLoadException e)
    {
        throw new SDLException("Could not load SDL TTF Library", "");
    }

    if (SDL_Init(SDL_INIT_VIDEO) > 0)
    {
        throw new SDLException("Failed to initialise SDL", to!string(SDL_GetError()));
    }

    TTF_Init();

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

class SDL
{
    public
    {

        this()
        {
        }

        ~this()
        {
            SDL_Quit();
        }

        SDL_Window* CreateWindow(immutable(char)* title, int x, int y, int w,
                int h, SDL_WindowFlags flags)
        {
            SDL_Window* win = null;

            if ((win = SDL_CreateWindow(title, x, y, w, h, flags)) == null)
            {
                throw new SDLException("Failed to create SDL window" ~ to!string(title),
                        to!string(SDL_GetError()));
            }

            return win;
        }

        SDL_Renderer* CreateRenderer(SDL_Window* window, int index, SDL_RendererFlags flags)
        {
            SDL_Renderer* ren = null;

            if ((ren = SDL_CreateRenderer(window, index, flags)) == null)
            {
                throw new SDLException("Failed to create renderer.", to!string(SDL_GetError()));
            }

            return ren;
        }

        SDL_Texture* CreateTextureFromSurface(SDL_Renderer* ren, SDL_Surface* surface)
        {
            SDL_Texture* new_texture = null;

            if ((new_texture = SDL_CreateTextureFromSurface(ren, surface)) == null)
            {
                throw new SDLException("Could not create text texture", to!string(SDL_GetError()));
            }

            return new_texture;
        }

        int SetRenderDrawColor(SDL_Renderer* ren, ubyte r, ubyte g, ubyte b, ubyte a)
        {
            return SDL_SetRenderDrawColor(ren, r, g, b, a);
        }

        int SetRenderFillRect(SDL_Renderer* ren, SDL_Rect* rect)
        {
            return SDL_RenderFillRect(ren, rect);
        }

        SDL_Surface* GetWindowSurface(SDL_Window* win)
        {
            SDL_Surface* sur = null;

            if ((sur = SDL_GetWindowSurface(win)) == null)
            {
                throw new SDLException("Could not get Window surface", to!string(SDL_GetError()));
            }

            return sur;
        }

        int RenderCopyEx(SDL_Renderer* ren, SDL_Texture* tex, SDL_Rect* clip,
                SDL_Rect* texture_space, double angle, SDL_Point* center, SDL_RendererFlip flip)
        {
            return SDL_RenderCopyEx(ren, tex, clip, texture_space, angle, center, flip);
        }

        int RenderFillRect(SDL_Renderer* ren, SDL_Rect* rect)
        {
            return SDL_RenderFillRect(ren, rect);
        }

        int RenderDrawLine(SDL_Renderer* ren, int x, int y, int x2, int y2)
        {
            return SDL_RenderDrawLine(ren, x, y, x2, y2);
        }

        int SaveBMP(SDL_Surface* surface, string filename)
        {
            return SDL_SaveBMP(surface, toStringz(filename));
        }

        void FreeSurface(SDL_Surface* surface)
        {
            SDL_FreeSurface(surface);
        }

        void DestroyTexture(SDL_Texture* texture)
        {
            SDL_DestroyTexture(texture);
        }

        void Delay(int time)
        {
            SDL_Delay(time);
        }

        void RenderPresent(SDL_Renderer* ren)
        {
            return SDL_RenderPresent(ren);
        }

        void RenderClear(SDL_Renderer* ren)
        {
            SDL_RenderClear(ren);
        }

        void DestroyWindow(SDL_Window* window)
        {
            return SDL_DestroyWindow(window);
        }

    }
}

class TTF
{

    public
    {
        this()
        {
        }

        ~this()
        {
            TTF_Quit();
        }

        SDL_Surface* RenderText_Solid(TTF_Font* font, immutable(char)* text, SDL_Color color)
        {
            SDL_Surface* new_surface = null;

            if ((new_surface = TTF_RenderText_Solid(font, text, color)) == null)
            {
                throw new SDLException("Could not create text surface", to!string(TTF_GetError()));
            }

            return new_surface;
        }

        TTF_Font* OpenFont(immutable(char)* file, int size)
        {
            TTF_Font* font;

            if ((font = TTF_OpenFont(file, size)) == null)
            {
                writeln(to!string(TTF_GetError()));
                throw new SDLException("Could not load font", to!string(TTF_GetError()));
            }

            return font;
        }
    }
}
