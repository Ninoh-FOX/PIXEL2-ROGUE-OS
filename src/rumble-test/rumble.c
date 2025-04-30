#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <linux/uinput.h>

int main() {
    int fd, ret;
    struct ff_effect effect = {
        .type = FF_RUMBLE,
        .id = -1,
        .u.rumble = {
            .strong_magnitude = 0xFFFF,  // Intensidad máxima (0-65535)
            .weak_magnitude = 0x0000,
        },
        .replay = {
            .length = 500,   // Duración en ms
            .delay = 0,
        },
    };

    fd = open("/dev/input/event2", O_RDWR);
    if (fd < 0) {
        perror("Error al abrir el dispositivo");
        return 1;
    }

    // Configurar el efecto
    ret = ioctl(fd, EVIOCSFF, &effect);
    if (ret < 0) {
        perror("Error al enviar el efecto");
        close(fd);
        return 1;
    }

    // Activar la vibración
    struct input_event play = {
        .type = EV_FF,
        .code = effect.id,
        .value = 1,
    };
    write(fd, &play, sizeof(play));

    // Mantener la vibración activa durante 500ms
    usleep(500000);

    // Detener la vibración
    play.value = 0;
    write(fd, &play, sizeof(play));

    // Liberar el efecto
    ioctl(fd, EVIOCRMFF, effect.id);
    close(fd);
    return 0;
}
