import logging

from core.validation.widgets.yasb.network import VALIDATION_SCHEMA
from core.widgets.base import BaseWidget
from humanize import naturalsize
from psutil import net_io_counters
from PyQt6.QtWidgets import QLabel


class NetworkWidget(BaseWidget):
    validation_schema = VALIDATION_SCHEMA

    def __init__(
        self,
        label: str,
        label_alt: str,
        update_interval: int,
        callbacks: dict[str, str],
    ):
        super().__init__(update_interval, class_name="network-widget")
        self._update_interval = update_interval
        self._bytes_sent_prev = 0
        self._bytes_recv_prev = 0

        self._show_alt_label = False
        self._label_content = label
        self._label_alt_content = label_alt

        self._label = QLabel()
        self._label_alt = QLabel()
        self._label.setProperty("class", "label")
        self._label_alt.setProperty("class", "label alt")
        self.widget_layout.addWidget(self._label)
        self.widget_layout.addWidget(self._label_alt)

        self.register_callback("toggle_label", self._toggle_label)
        self.register_callback("update_label", self._update_label)

        self.callback_left = callbacks["on_left"]
        self.callback_right = callbacks["on_right"]
        self.callback_middle = callbacks["on_middle"]
        self.callback_timer = "update_label"

        self._label.show()
        self._label_alt.hide()
        self.start_timer()

    def _toggle_label(self):
        self._show_alt_label = not self._show_alt_label

        if self._show_alt_label:
            self._label.hide()
            self._label_alt.show()
        else:
            self._label.show()
            self._label_alt.hide()

        self._update_label()

    def _update_label(self):
        if self._show_alt_label:
            active_label = self._label_alt
            active_label_content = self._label_alt_content
        else:
            active_label = self._label
            active_label_content = self._label_content
        active_label_formatted = active_label_content

        try:
            upload_speed, download_speed = self._get_speed()
            label_options = [
                ("{upload_speed}", str(naturalsize(upload_speed, gnu=True))),
                ("{download_speed}", str(naturalsize(download_speed, gnu=True))),
            ]
            for fmt_str, value in label_options:
                active_label_formatted = active_label_formatted.replace(
                    fmt_str,
                    value,
                )

            active_label.setText(active_label_formatted)
        except Exception:
            active_label.setText(active_label_content)
            logging.exception("Failed to retrieve updated network info")

    def _get_speed(self) -> tuple[float]:
        bytes_sent = net_io_counters().bytes_sent
        bytes_recv = net_io_counters().bytes_recv

        upload_speed = (bytes_sent - self._bytes_sent_prev) / (
            self._update_interval / 1000
        )
        download_speed = (bytes_recv - self._bytes_recv_prev) / (
            self._update_interval / 1000
        )

        self._bytes_sent_prev = bytes_sent
        self._bytes_recv_prev = bytes_recv

        return upload_speed, download_speed
