DEFAULTS = {
    'refresh_delay': 100,
    'min_refresh_interval': 400,
    'refresh_process_name_list': [],
}

VALIDATION_SCHEMA = {
    'refresh_delay': {
        'type': 'integer',
        'default': DEFAULTS['refresh_delay'],
        'min': 0,
        'max': 60000
    },
    'min_refresh_interval': {
        'type': 'integer',
        'default': DEFAULTS['min_refresh_interval'],
        'min': 0,
        'max': 60000
    },
    'refresh_process_name_list': {
        'type': 'list',
        'default': DEFAULTS['refresh_process_name_list'],
        "schema": {
            'type': 'string'
        }
    }
}
