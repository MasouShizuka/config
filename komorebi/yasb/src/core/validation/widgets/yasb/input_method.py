DEFAULTS = {
    "label": "\uf11c  {language}",
    "language_dict": {
        0x409: "EN",
        0x804: "\u4e2d",
    },
    "update_interval": 1000,
    "callbacks": {
        "on_left": "do_nothing",
        "on_middle": "do_nothing",
        "on_right": "do_nothing",
    },
}

VALIDATION_SCHEMA = {
    "label": {
        "type": "string",
        "default": DEFAULTS["label"],
    },
    "language_dict": {
        "type": "dict",
        "schema": {
            0x409: {
                "type": "string",
                "nullable": True,
                "default": DEFAULTS["language_dict"][0x409],
            },
            0x804: {
                "type": "string",
                "nullable": True,
                "default": DEFAULTS["language_dict"][0x804],
            },
        },
        "default": DEFAULTS["callbacks"],
    },
    "update_interval": {
        "type": "integer",
        "default": DEFAULTS["update_interval"],
        "min": 0,
        "max": 60000,
    },
    "callbacks": {
        "type": "dict",
        "schema": {
            "on_left": {
                "type": "string",
                "nullable": True,
                "default": DEFAULTS["callbacks"]["on_left"],
            },
            "on_middle": {
                "type": "string",
                "nullable": True,
                "default": DEFAULTS["callbacks"]["on_middle"],
            },
            "on_right": {
                "type": "string",
                "nullable": True,
                "default": DEFAULTS["callbacks"]["on_right"],
            },
        },
        "default": DEFAULTS["callbacks"],
    },
}
