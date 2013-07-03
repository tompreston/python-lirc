cdef extern from "lirc/lirc_client.h":
    cdef struct lirc_config:
        pass

    cdef struct lirc_code:
        pass

    int lirc_init(char *prog, int verbose)
    int lirc_deinit()

    #int lirc_readconfig(char *file,  lirc_config **config, int (check) (char *s))
    int lirc_readconfig(char *file,  lirc_config **config, void * check_callback)
    void lirc_freeconfig(lirc_config *config)

    int lirc_nextcode(char **code)
    int lirc_code2char(lirc_config *config, char *code, char **string)
