import os

from psutil import net_if_stats
from PyQt6.QtWidgets import QLabel

from core.validation.widgets.yasb.wifi import VALIDATION_SCHEMA
from core.widgets.base import BaseWidget


class WifiWidget(BaseWidget):
    validation_schema = VALIDATION_SCHEMA

    def __init__(
        self,
        label: str,
        label_alt: str,
        update_interval: int,
        wifi_icons: list[str],
        callbacks: dict[str, str],
    ):
        super().__init__(update_interval, class_name="wifi-widget")
        self._wifi_icons = wifi_icons

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
        wifi_icon = self._wifi_icons[0]
        wifi_name = ""
        for name in {name for name, net in net_if_stats().items() if net.isup}:
            name_lower = name.lower()
            if name_lower.startswith("eth") or name_lower.startswith("以太网"):
                wifi_name = name
                wifi_icon = self._wifi_icons[4]
                break
            elif name_lower == "wlan":
                wifi_name, wifi_icon = self._get_wifi_name_and_icon()
                break

        # Determine which label is active
        if self._show_alt_label:
            active_label = self._label_alt
            active_label_content = self._label_alt_content
        else:
            active_label = self._label
            active_label_content = self._label_content
        active_label_formatted = active_label_content

        try:
            label_options = [
                ("{wifi_icon}", wifi_icon),
                ("{wifi_name}", wifi_name),
            ]
            for fmt_str, value in label_options:
                active_label_formatted = active_label_formatted.replace(
                    fmt_str,
                    value,
                )

            active_label.setText(active_label_formatted)
        except Exception:
            active_label.setText(active_label_content)

    def _get_wifi_icon(self, strength):
        if strength == 0:
            return self._wifi_icons[0]
        elif strength <= 25:
            return self._wifi_icons[1]
        elif strength <= 50:
            return self._wifi_icons[2]
        elif strength <= 75:
            return self._wifi_icons[3]
        else:
            return self._wifi_icons[4]

    def _get_wifi_name_and_icon(self):
        result = os.popen("netsh wlan show interfaces").read()

        name = ""
        strength = 0
        for line in result.split("\n"):
            line = line.split()
            if "SSID" in line:
                name = line[2]
                continue
            if "Signal" in line or "信号" in line:  # FIXME: This will break if the system language is not English
                strength = int(line[2].replace("%", ""))
                break
        icon = self._get_wifi_icon(strength)

        return name, icon
