#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>
#include <linux/fb.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <linux/rtc.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <linux/joystick.h>
#include <SDL.h>
#include <SDL_ttf.h>

#define MAX_FONT    3
#define LCD_W       640
#define LCD_H       480
#define LCD_BPP     32
#define BG_COLOR    0x222222

static int is_ampm = 0;
static int is_pc = 0;
static struct tm rtc_time = {0};
static SDL_Window *window = NULL;
static SDL_Surface *screen = NULL;
static SDL_Texture *texture = NULL;
static SDL_Renderer *renderer = NULL;
static TTF_Font *font[MAX_FONT] = {0};
const int max_day[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

static void get_rtc(void)
{
    struct rtc_time rtc_time_raw;
    int fd = open("/dev/rtc0", O_RDWR);

    if (fd < 0) {
        return;
    }

    if (ioctl(fd, RTC_RD_TIME, &rtc_time_raw) < 0) {
        close(fd);
        return;
    }
    close(fd);

    struct tm utc_tm = {
        .tm_year = rtc_time_raw.tm_year,
        .tm_mon  = rtc_time_raw.tm_mon,
        .tm_mday = rtc_time_raw.tm_mday,
        .tm_hour = rtc_time_raw.tm_hour,
        .tm_min  = rtc_time_raw.tm_min,
        .tm_sec  = 0,
        .tm_isdst = -1
    };

    time_t utc_time = timegm(&utc_tm);
    struct tm *local_tm = localtime(&utc_time);

    if (local_tm) {
        rtc_time.tm_year = local_tm->tm_year;
        rtc_time.tm_mon  = local_tm->tm_mon;
        rtc_time.tm_mday = local_tm->tm_mday;
        rtc_time.tm_hour = local_tm->tm_hour;
        rtc_time.tm_min  = local_tm->tm_min;
        rtc_time.tm_sec  = 0;
    }
}

static void set_rtc(const char* timestamp)
{
    int imonth, iday, iyear, ihour, iminute;
    sscanf(timestamp, "%d-%d-%d %d:%d", &iyear, &imonth, &iday, &ihour, &iminute);
    struct tm datetime = {0};

    datetime.tm_year = iyear;
    datetime.tm_mon  = imonth;
    datetime.tm_mday = iday;
    datetime.tm_hour = ihour;
    datetime.tm_min  = iminute;
    datetime.tm_sec  = 0;
    datetime.tm_isdst = -1;

    if (datetime.tm_year < 0) {
        datetime.tm_year = 0;
    }

    time_t t = mktime(&datetime);
    struct timeval tv = {t, 0};
    settimeofday(&tv, NULL);
    system("hwclock -w --utc > /dev/null");

    int fd = open("/dev/rtc0", O_RDWR);
    if (fd > 0) {
        ioctl(fd, RTC_SET_TIME, t);
        close(fd);
    }
}

static void rotate_screen(void)
{
    SDL_Rect rt = {0, 0, LCD_W, LCD_H};

    if (is_pc == 0) {
        rt.x = (LCD_H - LCD_W) / 2;
        rt.y = (LCD_W - LCD_H) / 2;
        rt.w = LCD_W;
        rt.h = LCD_H;
    }
    SDL_SetRenderTarget(renderer, NULL);
    SDL_UpdateTexture(texture, NULL, screen->pixels, screen->pitch);
    SDL_RenderCopyEx(renderer, texture, NULL, &rt, is_pc ? 0 : 270, NULL, SDL_FLIP_NONE);
    SDL_SetRenderTarget(renderer, texture);
    SDL_RenderPresent(renderer);
}

static int get_text_width(const char *text, int idx)
{
    int ww = 0;
    int hh = 0;

    TTF_SizeUTF8(font[idx], text, &ww, &hh);
    return ww;
}

static void draw_text(const char *text, int idx, int x, int y, SDL_Color col)
{
    SDL_Rect rt = {x, y, 0, 0};
 
    SDL_Surface *msg = TTF_RenderUTF8_Solid(font[idx], text, col);
    SDL_BlitSurface(msg, NULL, screen, &rt);
    SDL_FreeSurface(msg);
}

static void fill_circle(int xx, int yy, int radius, uint32_t color)
{
    const int diameter = (radius * 2);

    int x = (radius - 1);
    int y = 0;
    int tx = 1;
    int ty = 1;
    int error = (tx - diameter);
    uint8_t *p = (uint8_t *)screen->pixels + (screen->pitch * yy) + (xx * screen->format->BytesPerPixel);

    while (x >= y) {
        for (int i = radius - x; i <= radius + x; i++) {
            *(uint32_t *)(p + screen->pitch * (radius + y) + (i * screen->format->BytesPerPixel)) = color;
            *(uint32_t *)(p + screen->pitch * (radius - y) + (i * screen->format->BytesPerPixel)) = color;
        }
        for (int i = radius - y; i <= radius + y; i++) {
            *(uint32_t *)(p + screen->pitch * (radius + x) + (i * screen->format->BytesPerPixel)) = color;
            *(uint32_t *)(p + screen->pitch * (radius - x) + (i * screen->format->BytesPerPixel)) = color;
        }

        if (error <= 0) {
            y += 1;
            error += ty;
            ty += 2;
        }

        if (error > 0) {
            x -= 1;
            tx += 2;
            error += (tx - diameter);
        }
    }
}

static void draw_block(int r, int x0, int y0, int x1, int y1)
{
    SDL_Rect rt = {0};

    fill_circle(x0, y0, r, BG_COLOR);
    fill_circle(x0, y1, r, BG_COLOR);
    fill_circle(x1, y0, r, BG_COLOR);
    fill_circle(x1, y1, r, BG_COLOR);

    rt.x = x0 + 1;
    rt.y = y0 + (r / 2);
    rt.w = (x1 - x0) + (r * 2) - 1;
    rt.h = (y1 - y0) + r + 1;
    SDL_FillRect(screen, &rt, SDL_MapRGB(screen->format, BG_COLOR >> 16, BG_COLOR, BG_COLOR));

    rt.x = x0 + (r / 2);
    rt.y = y0 + 1;
    rt.w = (x1 - x0) + r + 1;
    rt.h = (y1 - y0) + (r * 2) - 1;
    SDL_FillRect(screen, &rt, SDL_MapRGB(screen->format, BG_COLOR >> 16, BG_COLOR, BG_COLOR));
}

static void draw_time(int sel, int wr)
{
    int w = 0;
    int h = 0;
    SDL_Rect rt = {0};
    char buf[255] = {0};

    if (wr) {
        SDL_FillRect(screen, &screen->clip_rect, SDL_MapRGB(screen->format, 0x00, 0x40, 0x00));
    }
    else {
        SDL_FillRect(screen, &screen->clip_rect, SDL_MapRGB(screen->format, 0x00, 0x00, 0x00));
    }

    draw_block(10, 15, 88, 15 + 265, 290);
    draw_block(10, 337, 88, 337 + 265, 290);

    int mon = rtc_time.tm_mon + 1;
    int year = rtc_time.tm_year + 1900;
    int hour = rtc_time.tm_hour;

    if (mon > 12) {
        mon = 1;
    }
    if (is_ampm) {
        hour %= 12;
        if (hour == 0) {
            hour = 12;
        }

        sprintf(buf, "%s", rtc_time.tm_hour < 12 ? "AM" : "PM");
        draw_text(buf, 2, 20, 40, (SDL_Color){0xba, 0xba, 0xba});
    }

    sprintf(buf, "%d", hour / 10);
    draw_text(buf, 1, 15, 50, sel == 3 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    draw_text(":", 1, 285, 50, (SDL_Color){0xba, 0xba, 0xba});

    sprintf(buf, "%d", hour % 10);
    draw_text(buf, 1, 15 + 135, 50, sel == 3 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    sprintf(buf, "%d", rtc_time.tm_min / 10);
    draw_text(buf, 1, 335, 50, sel == 4 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    sprintf(buf, "%d", rtc_time.tm_min % 10);
    draw_text(buf, 1, 335 + 135, 50, sel == 4 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w = 60;
    h = 310;
    sprintf(buf, "%d", year / 1000);
    draw_text(buf, 0, w, h, sel == 0 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    sprintf(buf, "%d", (year / 100) % 10);
    draw_text(buf, 0, w, h, sel == 0 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    sprintf(buf, "%d", (year / 10) % 10);
    draw_text(buf, 0, w, h, sel == 0 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    sprintf(buf, "%d", year % 10);
    draw_text(buf, 0, w, h, sel == 0 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    draw_text("-", 0, w, h, (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    sprintf(buf, "%d", mon / 10);
    draw_text(buf, 0, w, h, sel == 1 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    sprintf(buf, "%d", mon % 10);
    draw_text(buf, 0, w, h, sel == 1 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    draw_text("-", 0, w, h, (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    sprintf(buf, "%d", rtc_time.tm_mday / 10);
    draw_text(buf, 0, w, h, sel == 2 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    w += 50;
    sprintf(buf, "%d", rtc_time.tm_mday % 10);
    draw_text(buf, 0, w, h, sel == 2 ? (SDL_Color){0xff, 0x00, 0x00} : (SDL_Color){0xba, 0xba, 0xba});

    rt.x = 0;
    rt.y = 198;
    rt.w = 640;
    rt.h = 5;
    SDL_FillRect(screen, &rt, SDL_MapRGB(screen->format, 0, 0, 0));
}

int main(int argc, char **argv)
{
    int cc = 0;
    SDL_Rect rt = {0};
    char buf[255] = {0};

//#ifdef PC
    is_pc = 1;
//#endif

	struct input_event ev;
    int fd = open("/dev/input/event2", O_RDONLY | O_NONBLOCK);
	
    SDL_Init(SDL_INIT_VIDEO);
    window = SDL_CreateWindow("main", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, is_pc ? LCD_W : LCD_H, is_pc ? LCD_H : LCD_W, SDL_WINDOW_SHOWN);
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    screen = SDL_CreateRGBSurface(0, LCD_W, LCD_H, LCD_BPP, 0, 0, 0, 0);
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STREAMING, LCD_W, LCD_H);
 
    TTF_Init();
    const char *FONT = "font.ttf";
    font[0] = TTF_OpenFont(FONT, 100);
    font[1] = TTF_OpenFont(FONT, 300);
    font[2] = TTF_OpenFont(FONT, 50);

    //SDL_Event event = {0};

    int pos = 0;
    int updated = 0; 
    int running = 1;

    get_rtc();
    draw_time(pos, 0);
    rotate_screen();
    while (running) {
		while (read(fd, &ev, sizeof(ev)) > 0) {
        if (ev.type == EV_KEY) {
            if (ev.value == 1) {
                if(ev.code == BTN_TRIGGER_HAPPY1){
                    running = 0;
                    break;
                }
                if(ev.code == BTN_START){
                    is_ampm = is_ampm ? 0 : 1;
                }
                if(ev.code == BTN_SOUTH){
                    running = 0;
                    break;
                }
                if(ev.code == BTN_EAST){
                    sprintf(buf, "%d-%d-%d %d:%d", rtc_time.tm_year, rtc_time.tm_mon, rtc_time.tm_mday, rtc_time.tm_hour, rtc_time.tm_min);
                    set_rtc(buf);

                    draw_time(pos, 1);
                    rotate_screen();
                    SDL_Delay(1000);
                }
                
                if(ev.code == BTN_DPAD_LEFT){
                    if (pos > 0) {
                        pos-= 1;
                    }
                }
                if(ev.code == BTN_DPAD_RIGHT){
                    if (pos <= 3) {
                        pos+= 1;
                    }
                }
                if(ev.code == BTN_DPAD_UP){
                    switch (pos) {
                    case 0:
                        rtc_time.tm_year+= 1;
                        break;
                    case 1:
                        rtc_time.tm_mon+= 1;
                        break;
                    case 2:
                        rtc_time.tm_mday+= 1;
                        break;
                    case 3:
                        rtc_time.tm_hour+= 1;
                        break;
                    case 4:
                        rtc_time.tm_min+= 1;
                        break;
                    }
                }
                if(ev.code == BTN_DPAD_DOWN){
                    switch (pos) {
                    case 0:
                        rtc_time.tm_year-= 1;
                        break;
                    case 1:
                        rtc_time.tm_mon-= 1;
                        break;
                    case 2:
                        rtc_time.tm_mday-= 1;
                        break;
                    case 3:
                        rtc_time.tm_hour-= 1;
                        break;
                    case 4:
                        rtc_time.tm_min-= 1;
                        break;
                    }
                }

                if (rtc_time.tm_mon < 0) {
                    rtc_time.tm_mon = 11;
                    if (rtc_time.tm_mday > max_day[rtc_time.tm_mon]) rtc_time.tm_mday = 1;
                }
                if (rtc_time.tm_mon > 11) {
                    rtc_time.tm_mon = 0;
                    if (rtc_time.tm_mday > max_day[rtc_time.tm_mon]) rtc_time.tm_mday = 1;
                }
                if (rtc_time.tm_mday <= 0) rtc_time.tm_mday = max_day[rtc_time.tm_mon];
                if (rtc_time.tm_mday > max_day[rtc_time.tm_mon]) rtc_time.tm_mday = 1;
                if (rtc_time.tm_hour < 0) rtc_time.tm_hour = 23;
                if (rtc_time.tm_hour > 23) rtc_time.tm_hour = 0;
                if (rtc_time.tm_min < 0) rtc_time.tm_min = 59;
                if (rtc_time.tm_min > 59) rtc_time.tm_min = 0;
            }
        }
		}

        updated = 1;
        if (updated) {
            updated = 0;
            draw_time(pos, 0);
            rotate_screen();
        }
        SDL_Delay(10);
    }

    for (cc = 0; cc < MAX_FONT; cc++) {
        if (font[cc]) {
            TTF_CloseFont(font[cc]);
        }
    }

    TTF_Quit();
    SDL_FreeSurface(screen);
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}