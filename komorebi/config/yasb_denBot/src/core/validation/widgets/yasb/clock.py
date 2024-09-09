DEFAULTS = {
    "label": "\uf017 {%H:%M:%S}",
    "label_alt": "\uf017 {%d-%m-%y %H:%M:%S}",
    "update_interval": 1000,
    "timezones": [],
    "status_icons": {
        "icon_0": "\ue381",
        "icon_1": "\ue382",
        "icon_2": "\ue383",
        "icon_3": "\ue384",
        "icon_4": "\ue385",
        "icon_5": "\ue386",
        "icon_6": "\ue387",
        "icon_7": "\ue388",
        "icon_8": "\ue389",
        "icon_9": "\ue38a",
        "icon_10": "\ue38b",
        "icon_11": "\ue38c",
    },
    "callbacks": {
        "on_left": "toggle_label",
        "on_middle": "do_nothing",
        "on_right": "next_timezone",
    },
}

VALIDATION_SCHEMA = {
    "label": {"type": "string", "default": DEFAULTS["label"]},
    "label_alt": {"type": "string", "default": DEFAULTS["label_alt"]},
    "update_interval": {"type": "integer", "default": 1000, "min": 0, "max": 60000},
    "timezones": {
        "type": "list",
        "default": DEFAULTS["timezones"],
        "schema": {"type": "string", "required": False},
    },
    "status_icons": {
        "type": "dict",
        "schema": {
            "icon_0": {"type": "string", "default": DEFAULTS["status_icons"]["icon_0"]},
            "icon_1": {"type": "string", "default": DEFAULTS["status_icons"]["icon_1"]},
            "icon_2": {"type": "string", "default": DEFAULTS["status_icons"]["icon_2"]},
            "icon_3": {"type": "string", "default": DEFAULTS["status_icons"]["icon_3"]},
            "icon_4": {"type": "string", "default": DEFAULTS["status_icons"]["icon_4"]},
            "icon_5": {"type": "string", "default": DEFAULTS["status_icons"]["icon_5"]},
            "icon_6": {"type": "string", "default": DEFAULTS["status_icons"]["icon_6"]},
            "icon_7": {"type": "string", "default": DEFAULTS["status_icons"]["icon_7"]},
            "icon_8": {"type": "string", "default": DEFAULTS["status_icons"]["icon_8"]},
            "icon_9": {"type": "string", "default": DEFAULTS["status_icons"]["icon_9"]},
            "icon_10": {
                "type": "string",
                "default": DEFAULTS["status_icons"]["icon_10"],
            },
            "icon_11": {
                "type": "string",
                "default": DEFAULTS["status_icons"]["icon_11"],
            },
        },
        "default": DEFAULTS["status_icons"],
    },
    "callbacks": {
        "type": "dict",
        "schema": {
            "on_left": {
                "type": "string",
                "default": DEFAULTS["callbacks"]["on_left"],
            },
            "on_middle": {
                "type": "string",
                "default": DEFAULTS["callbacks"]["on_middle"],
            },
            "on_right": {
                "type": "string",
                "default": DEFAULTS["callbacks"]["on_right"],
            },
        },
        "default": DEFAULTS["callbacks"],
    },
}
