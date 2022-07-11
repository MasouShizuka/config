DEFAULTS = {
    "label": '{win[title]}',
    'label_alt': '[class={win[class_name]} exe={win[exe]} hwnd={win[hwnd]}]',
    'show_icon': True,
    'update_title': {
        'live_update': True,
        'update_interval': 1000
    },
    'callbacks': {
        'on_left': 'do_nothing',
        'on_middle': 'do_nothing',
        'on_right': 'toggle_label'
    }
}

VALIDATION_SCHEMA = {
    'label': {
        'type': 'string',
        'default': DEFAULTS['label']
    },
    'label_alt': {
        'type': 'string',
        'default': DEFAULTS['label_alt']
    },
    'show_icon': {
        'type': 'boolean',
        'default': DEFAULTS['show_icon']
    },
    'update_title': {
        'type': 'dict',
        'schema': {
            'live_update': {
                'type': 'boolean',
                'default': DEFAULTS['update_title']['live_update']
            },
            'update_interval': {
                'type': 'integer',
                'default': DEFAULTS['update_title']['update_interval'],
                'min': 0,
                'max': 60000
            }
        },
        'default': DEFAULTS['update_title']
    },
    'callbacks': {
        'type': 'dict',
        'schema': {
            'on_left': {
                'type': 'string',
                'default': DEFAULTS['callbacks']['on_left'],
            },
            'on_middle': {
                'type': 'string',
                'default': DEFAULTS['callbacks']['on_middle'],
            },
            'on_right': {
                'type': 'string',
                'default': DEFAULTS['callbacks']['on_right']
            }
        },
        'default': DEFAULTS['callbacks']
    }
}
