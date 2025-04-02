#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


#define SCREEN_WIDTH  640
#define SCREEN_HEIGHT 480

int main(int argc, char* argv[]) {
    if (argc < 2) {
        puts("Usage: show /path/image.png");
        return EXIT_SUCCESS;
    }

    if (access(argv[1], F_OK) != 0) return EXIT_FAILURE;

    // Inicializar SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        fprintf(stderr, "SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return EXIT_FAILURE;
    }

    // Crear ventana y renderer
    SDL_Window* window = SDL_CreateWindow("Show Screen",
                                          SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                          SCREEN_WIDTH, SCREEN_HEIGHT,
                                          SDL_WINDOW_FULLSCREEN);
    if (!window) {
        fprintf(stderr, "Window could not be created! SDL_Error: %s\n", SDL_GetError());
        SDL_Quit();
        return EXIT_FAILURE;
    }

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        fprintf(stderr, "Renderer could not be created! SDL_Error: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }

    // Cargar la imagen original
    SDL_Surface* img_surface = IMG_Load(argv[1]);
    if (!img_surface) {
        fprintf(stderr, "Unable to load image! IMG_Error: %s\n", IMG_GetError());
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }

    // Convertir la imagen a formato RGB sin alpha
    SDL_Surface* rgb_surface = SDL_ConvertSurfaceFormat(img_surface, SDL_PIXELFORMAT_RGB888, 0);
    SDL_FreeSurface(img_surface); // Liberar la imagen original
    if (!rgb_surface) {
        fprintf(stderr, "Error converting image to RGB: %s\n", SDL_GetError());
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }

    // Crear textura desde la imagen
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, rgb_surface);
    SDL_FreeSurface(rgb_surface);
    if (!texture) {
        fprintf(stderr, "Unable to create texture! SDL_Error: %s\n", SDL_GetError());
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }

    // Limpiar pantalla y mostrar imagen escalada
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);

    // Esperar tiempo de salida
	SDL_Delay(5000);

    // Liberar recursos
    SDL_DestroyTexture(texture);
	SDL_FreeSurface(rgb_surface);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return EXIT_SUCCESS;
}
