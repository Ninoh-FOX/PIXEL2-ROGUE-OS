#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <linux/joystick.h>
#include <sys/ioctl.h>
#include <time.h>
#include <signal.h>
#include <string.h>
#include <dirent.h>
#include <pwd.h>
#include <SDL2/SDL.h>


#define DEVICE "/dev/input/event2"
#define MOVE_INTERVAL_MS 20
#define MOVE_STEP 10
#define CLICK_DEBOUNCE_MS 50
#define DEFAULT_SCREEN_WIDTH 640
#define DEFAULT_SCREEN_HEIGHT 480
#define DEFAULT_CONFIG_PATH "/storage/.config/dpadmouse.cfg"

struct {
    int up;
    int down;
    int left;
    int right;
    int posX;
    int posY;
} dpad_state = {.posX = DEFAULT_SCREEN_WIDTH / 2, .posY = DEFAULT_SCREEN_HEIGHT / 2};

int key_mode_toggle = BTN_TL2;
int key_mouse_left = BTN_TR;
int key_mouse_right = -1;
int cursor_speed = MOVE_STEP;

int screen_width = DEFAULT_SCREEN_WIDTH;
int screen_height = DEFAULT_SCREEN_HEIGHT;

struct {
    const char *name;
    int code;
} key_map[] = {
    {"A", BTN_EAST}, {"B", BTN_SOUTH}, {"X", BTN_NORTH}, {"Y", BTN_WEST},
    {"L1", BTN_TL}, {"R1", BTN_TR}, {"L2", BTN_TL2}, {"R2", BTN_TR2},
    {"SELECT", BTN_SELECT}, {"START", BTN_START}, {"MENU", BTN_TRIGGER_HAPPY1},
    {NULL, -1}
};

void get_screen_resolution() {
    FILE *fp = popen("fbset -s 2>/dev/null | grep geometry", "r");
    if (fp) {
        if (fscanf(fp, " geometry %d %d", &screen_width, &screen_height) != 2) {
            FILE *fb = fopen("/sys/class/graphics/fb0/virtual_size", "r");
            if (fb && fscanf(fb, "%d,%d", &screen_width, &screen_height) != 2) {
                screen_width = DEFAULT_SCREEN_WIDTH;
                screen_height = DEFAULT_SCREEN_HEIGHT;
            }
            if (fb) fclose(fb);
        }
        pclose(fp);
    }
}

int get_key_code(const char *key_name) {
    for (int i = 0; key_map[i].name; i++) {
        if (strcmp(key_name, key_map[i].name) == 0) return key_map[i].code;
    }
    return -1;
}

void sdl_nomouse() {
    SDL_ShowCursor(SDL_DISABLE);
	SDL_SetRelativeMouseMode(SDL_TRUE);
}

void create_default_config(const char *config_path) {
    FILE *file = fopen(config_path, "w");
    fprintf(file, "mode_toggle = L2\n");
    fprintf(file, "mouse_left = R1\n");
    fprintf(file, "mouse_right = -1\n");
	fprintf(file, "cursor_speed = 10\n");
    fclose(file);
}

void load_config(const char *config_path) {
    FILE *file = fopen(config_path, "r");
    if (!file) {
        create_default_config(config_path);
        file = fopen(config_path, "r");
        if (!file) {
            return;
        }
    }
	
    char key[32], value[32];
    while (fscanf(file, "%31s = %31s", key, value) == 2) {
        if (strcmp(key, "mode_toggle") == 0) key_mode_toggle = get_key_code(value);
        else if (strcmp(key, "mouse_left") == 0) key_mouse_left = get_key_code(value);
        else if (strcmp(key, "mouse_right") == 0) key_mouse_right = get_key_code(value);
        else if (strcmp(key, "cursor_speed") == 0) cursor_speed = atoi(value);
    }
    fclose(file);
}

int setup_uinput_device(int uinput_fd) {
    struct uinput_setup usetup = {
        .id = {.bustype = BUS_USB, .vendor = 0x1, .product = 0x2102},
        .name = "Virtual Mouse"
    };

    ioctl(uinput_fd, UI_SET_EVBIT, EV_KEY);
    ioctl(uinput_fd, UI_SET_KEYBIT, BTN_LEFT);
    if (key_mouse_right != -1) ioctl(uinput_fd, UI_SET_KEYBIT, BTN_RIGHT);

    ioctl(uinput_fd, UI_SET_EVBIT, EV_ABS);
    ioctl(uinput_fd, UI_SET_ABSBIT, ABS_X);
    ioctl(uinput_fd, UI_SET_ABSBIT, ABS_Y);

    struct uinput_abs_setup abs_setup = {
        .code = ABS_X,
        .absinfo = {.value = dpad_state.posX, .minimum = 0, .maximum = screen_width}
    };
    ioctl(uinput_fd, UI_ABS_SETUP, &abs_setup);

    abs_setup.code = ABS_Y;
    abs_setup.absinfo.value = dpad_state.posY;
    abs_setup.absinfo.maximum = screen_height;
    ioctl(uinput_fd, UI_ABS_SETUP, &abs_setup);

    ioctl(uinput_fd, UI_DEV_SETUP, &usetup);
    ioctl(uinput_fd, UI_DEV_CREATE);
    
    return 0;
}

void send_mouse_event(int uinput_fd) {
    struct input_event events[3] = {
        {.type = EV_ABS, .code = ABS_X, .value = dpad_state.posX},
        {.type = EV_ABS, .code = ABS_Y, .value = dpad_state.posY},
        {.type = EV_SYN, .code = SYN_REPORT, .value = 0}
    };
    write(uinput_fd, events, sizeof(events));
}

void send_click(int uinput_fd, int btn_code, int value) {
    struct input_event events[2] = {
        {.type = EV_KEY, .code = btn_code, .value = value},
        {.type = EV_SYN, .code = SYN_REPORT, .value = 0}
    };
    write(uinput_fd, events, sizeof(events));
}

int main(int argc, char *argv[]) {
    get_screen_resolution();
    const char *config_path = DEFAULT_CONFIG_PATH;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-c") == 0 && i + 1 < argc) {
            config_path = argv[++i];
        }
    }
    load_config(config_path);

    int fd = open(DEVICE, O_RDWR | O_NONBLOCK);
    if (fd < 0) {
        return 1;
    }

    int uinput_fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (uinput_fd < 0) {
        close(fd);
        return 1;
    }

    setup_uinput_device(uinput_fd);
    send_mouse_event(uinput_fd);
    sdl_nomouse();

    struct input_event ev;
    int mode = 0;
    struct timespec last_move, last_click;

    clock_gettime(CLOCK_MONOTONIC, &last_move);
    clock_gettime(CLOCK_MONOTONIC, &last_click);

    while (1) {
        struct timespec now;
        clock_gettime(CLOCK_MONOTONIC, &now);

        while (read(fd, &ev, sizeof(ev)) > 0) {
            if (ev.type == EV_KEY) {
                if (ev.code == key_mode_toggle && ev.value == 1) {
                    mode = !mode;
                    printf("Modo: %s\n", mode ? "Mouse" : "D-Pad");
                } else if (mode) {
					ioctl(fd, EVIOCGRAB, 1);
                    if (ev.code == BTN_DPAD_UP) dpad_state.up = ev.value;
                    if (ev.code == BTN_DPAD_DOWN) dpad_state.down = ev.value;
                    if (ev.code == BTN_DPAD_LEFT) dpad_state.left = ev.value;
                    if (ev.code == BTN_DPAD_RIGHT) dpad_state.right = ev.value;
                    if (ev.code == key_mouse_left) send_click(uinput_fd, BTN_LEFT, ev.value);
                    if (ev.code == key_mouse_right && key_mouse_right != -1) send_click(uinput_fd, BTN_RIGHT, ev.value);
                } else {
					ioctl(fd, EVIOCGRAB, 0);
				}
            }
        }

        if (mode) {
            long elapsed = (now.tv_sec - last_move.tv_sec) * 1000 +
                          (now.tv_nsec - last_move.tv_nsec) / 1000000;

            if (elapsed >= 20) {
                if (dpad_state.up) dpad_state.posY = dpad_state.posY > 0 ? dpad_state.posY - cursor_speed : 0;
                if (dpad_state.down) dpad_state.posY = dpad_state.posY < screen_height ? dpad_state.posY + cursor_speed : screen_height;
                if (dpad_state.left) dpad_state.posX = dpad_state.posX > 0 ? dpad_state.posX - cursor_speed : 0;
                if (dpad_state.right) dpad_state.posX = dpad_state.posX < screen_width ? dpad_state.posX + cursor_speed : screen_width;
                
                send_mouse_event(uinput_fd);
                last_move = now;
            }
        }
    }

    close(uinput_fd);
    close(fd);
    return 0;
}
