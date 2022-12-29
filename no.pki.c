#define _GNU_SOURCE

#include <stdbool.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>
#ifdef TEST
        #include <limits.h>
        #include <stdio.h>
        #include <assert.h>
#endif

#ifdef __APPLE__
        struct dyld_interpose {
                const void *replacement;
                const void *replacee;
        };
        #define WRAPPER(ret, name) static ret _no_pki_wrapper_##name
        #define LOOKUP_REAL(name) &name
        #define WRAPPER_DEF(name)                                                           \
                __attribute__((used)) static struct dyld_interpose _no_pki_interpose_##name \
                    __attribute__((section("__DATA,__interpose"))) = {&_no_pki_wrapper_##name, &name};
#else
        #define WRAPPER(ret, name) ret name
        #define LOOKUP_REAL(name) dlsym(RTLD_NEXT, #name)
        #define WRAPPER_DEF(name)
#endif

static bool should_deny(const char *path) {
        const char *home = getenv("HOME");

        if (home != NULL && home[0] == '/' && home[1] == '\0') {
                home = "";
        }

        size_t home_len = home == NULL ? 0 : strlen(home);
        size_t path_len = strlen(path);

        return (home == NULL || strncmp(path, home, home_len) == 0)
                && path_len > home_len
                && strcmp(path + home_len, "/.pki") == 0;
}

WRAPPER(int, mkdir)(const char *path, mode_t mode) {
        if (should_deny(path)) {
                errno = EACCES;
                return -1;
        }

        int (*mkdir_real)(const char *path, mode_t mode) = LOOKUP_REAL(mkdir);
        return mkdir_real(path, mode);
}
WRAPPER_DEF(mkdir)

#ifdef TEST
int main() {
        const char *home = getenv("HOME");
        char buf[PATH_MAX];

        snprintf(buf, sizeof(buf), ".pki");
        assert(should_deny(buf) == false);

        snprintf(buf, sizeof(buf), "%s", home);
        assert(should_deny(buf) == false);

        snprintf(buf, sizeof(buf), "%s/foo", home);
        assert(should_deny(buf) == false);

        snprintf(buf, sizeof(buf), "%s/.pkix", home);
        assert(should_deny(buf) == false);

        snprintf(buf, sizeof(buf), "/.pki");
        assert(should_deny(buf) == false);

        snprintf(buf, sizeof(buf), "/not-home/.pki");
        assert(should_deny(buf) == false);

        snprintf(buf, sizeof(buf), "%s/.pki", home);
        assert(should_deny(buf) == true);

        setenv("HOME", "/a", 1);
        snprintf(buf, sizeof(buf), "/a/.pki");
        assert(should_deny(buf) == true);

        setenv("HOME", "/", 1);
        snprintf(buf, sizeof(buf), "/.pki");
        assert(should_deny(buf) == true);

        snprintf(buf, sizeof(buf), ".pki");
        assert(should_deny(buf) == false);

        setenv("HOME", "", 1);
        snprintf(buf, sizeof(buf), "/.pki");
        assert(should_deny(buf) == true);

        snprintf(buf, sizeof(buf), ".pki");
        assert(should_deny(buf) == false);

        unsetenv("HOME");
        snprintf(buf, sizeof(buf), "/.pki");
        assert(should_deny(buf) == true);

        snprintf(buf, sizeof(buf), ".pki");
        assert(should_deny(buf) == false);
}
#endif
