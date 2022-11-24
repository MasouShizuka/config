DEFAULTS = {
    "refresh_delay": 100,
    "min_interval": 1000,
    "refresh_process_name_list": [],
}

VALIDATION_SCHEMA = {
    "refresh_delay": {
        "type": "integer",
        "default": DEFAULTS["refresh_delay"],
        "min": 0,
        "max": 60000,
    },
    "min_interval": {
        "type": "integer",
        "default": DEFAULTS["min_interval"],
        "min": 0,
        "max": 60000,
    },
    "refresh_process_name_list": {
        "type": "list",
        "default": DEFAULTS["refresh_process_name_list"],
        "schema": {
            "type": "string",
        },
    },
}
