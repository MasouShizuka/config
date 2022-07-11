import logging
from ctypes import WinDLL

from core.validation.widgets.yasb.input_method import VALIDATION_SCHEMA
from core.widgets.base import BaseWidget
from PyQt6.QtWidgets import QLabel


class InputMethodWidget(BaseWidget):
    validation_schema = VALIDATION_SCHEMA

    def __init__(
        self,
        label: str,
        language_dict: dict[int: str],
        update_interval: int,
        callbacks: dict[str, str],
    ):
        super().__init__(update_interval, class_name='input-method-widget')
        self._user32 = WinDLL('user32', use_last_error=True)
        self._language_dict = language_dict

        self._label_content = label

        self._label = QLabel()
        self._label.setProperty('class', 'label')
        self.widget_layout.addWidget(self._label)

        self.register_callback('update_label', self._update_label)

        self.callback_left = callbacks['on_left']
        self.callback_right = callbacks['on_right']
        self.callback_middle = callbacks['on_middle']
        self.callback_timer = 'update_label'

        self.start_timer()

    def _update_label(self):
        label_formatted = self._label_content
        try:
            language_id = self._get_language_id()
            label_formatted = label_formatted.replace(
                '{language}',
                self._language_dict[language_id],
            )

            self._label.setText(label_formatted)
        except Exception:
            self._label.setText(self._label_content)
            logging.exception('Failed to retrieve updated network info')

    def _get_language_id(self) -> int:
        hwnd = self._user32.GetForegroundWindow()
        tid = self._user32.GetWindowThreadProcessId(hwnd, 0)
        language_id = self._user32.GetKeyboardLayout(tid) & 0xFFF

        return language_id
