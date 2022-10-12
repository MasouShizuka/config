import logging
from time import time

from core.event_enums import KomorebiEvent
from core.event_service import EventService
from core.utils.komorebi.client import KomorebiClient
from core.utils.win32.utilities import get_monitor_hwnd
from core.validation.widgets.komorebi.multi_window import VALIDATION_SCHEMA
from core.widgets.base import BaseWidget
from psutil import Process
from PyQt6.QtCore import pyqtSignal
from PyQt6.QtGui import QIcon, QImage, QPixmap
from PyQt6.QtWidgets import QHBoxLayout, QPushButton, QWidget
from win32gui import (
    DestroyIcon,
    DrawIconEx,
    ExtractIconEx,
    GetDC,
    GetWindowText,
    SetForegroundWindow,
)
from win32process import GetWindowThreadProcessId
from win32ui import CreateBitmap, CreateDCFromHandle

try:
    from core.utils.komorebi.event_listener import KomorebiEventListener
except ImportError:
    KomorebiEventListener = None
    logging.warning('Failed to load Komorebi Event Listener')


class WindowButton(QPushButton):
    def __init__(self, window_info: dict, label: str):
        super().__init__()
        self.window_info = window_info

        self.setProperty('class', 'window')
        self.setText(label.format(win=window_info))
        self.clicked.connect(self.set_focus)

    def update_focused(self):
        self.setProperty('class', f'window-focused')
        self.setStyleSheet('')

    def update_unfocused(self):
        self.setProperty('class', f'window')
        self.setStyleSheet('')

    def set_focus(self):
        SetForegroundWindow(self.window_info['hwnd'])


class MultiWindowWidget(BaseWidget):
    k_signal_connect = pyqtSignal(dict)
    k_signal_window_change = pyqtSignal(dict, dict)

    validation_schema = VALIDATION_SCHEMA
    event_listener = KomorebiEventListener

    def __init__(
        self,
        label: str,
        label_alt: str,
        show_icon: bool,
        min_update_interval: int,
        update_title: dict,
        callbacks: dict[str, str],
    ):
        super().__init__(
            update_title['update_interval'], class_name='komorebi-multi-window'
        )
        self._label = label
        self._label_alt = label_alt
        self._show_alt = False
        self._active_label = label

        self._show_icon = show_icon

        self._min_update_interval = min_update_interval
        self._last_update_time = 0

        self._event_service = EventService()
        self._komorebic = KomorebiClient()
        self._komorebi_screen = None
        self._komorebi_workspaces = []
        self._focused_workspace = {}
        self._window_buttons: list[WindowButton] = []

        self._multi_window_container_layout: QHBoxLayout = QHBoxLayout()
        self._multi_window_container_layout.setSpacing(0)
        self._multi_window_container_layout.setContentsMargins(0, 0, 0, 0)
        self._multi_window_container: QWidget = QWidget()
        self._multi_window_container.setLayout(self._multi_window_container_layout)
        self._multi_window_container.setProperty(
            'class',
            'komorebi-workspaces-container',
        )

        self.widget_layout.addWidget(self._multi_window_container)
        self.register_callback('toggle_label', self._toggle_title_text)
        self.register_callback(
            '_update_workspace_windows_title', self._update_workspace_windows_title
        )

        self.callback_left = callbacks['on_left']
        self.callback_right = callbacks['on_right']
        self.callback_middle = callbacks['on_middle']
        self.callback_timer = '_update_workspace_windows_title'

        if update_title['live_update']:
            self.start_timer()

        self._register_signals_and_events()

    def _register_signals_and_events(self):
        window_change_event_watchlist = [
            KomorebiEvent.ToggleMonocle,
            KomorebiEvent.CycleFocusMonitor,
            KomorebiEvent.CycleFocusWorkspace,
            KomorebiEvent.CycleFocusWindow,
            KomorebiEvent.FocusChange,
            KomorebiEvent.FocusMonitorNumber,
            KomorebiEvent.FocusWorkspaceNumber,
            KomorebiEvent.FocusMonitorWorkspaceNumber,
            KomorebiEvent.PromoteFocus,
            KomorebiEvent.CycleMoveWindow,
            KomorebiEvent.Promote,
            KomorebiEvent.Manage,
            KomorebiEvent.Unmanage,
        ]

        self.k_signal_connect.connect(self._on_komorebi_connect_event)
        self.k_signal_window_change.connect(self._on_komorebi_window_change_event)

        self._event_service.register_event(
            KomorebiEvent.KomorebiConnect, self.k_signal_connect
        )

        for event_type in window_change_event_watchlist:
            self._event_service.register_event(event_type, self.k_signal_window_change)

    def _toggle_title_text(self):
        self._show_alt = not self._show_alt
        self._active_label = self._label_alt if self._show_alt else self._label

    def _on_komorebi_connect_event(self, state: dict):
        self._update_workspace_windows(state)

    def _on_komorebi_window_change_event(self, event: dict, state: dict):
        prev_last_update_time = self._last_update_time
        last_update_time = round(time() * 1000)
        if last_update_time - prev_last_update_time >= self._min_update_interval:
            self._last_update_time = last_update_time
            self._update_workspace_windows(state)

    def _update_workspace_windows(self, state: dict):
        try:
            if self._update_komorebi_state(state):
                self._focused_workspace = self._komorebic.get_focused_workspace(
                    self._komorebi_screen
                )

                if not self._focused_workspace:
                    return

                self._clear_container_layout()

                windows = self._focused_workspace['containers']['elements']
                focused_window_index = self._focused_workspace['containers']['focused']
                if self._focused_workspace['monocle_container'] is not None:
                    windows.insert(0, self._focused_workspace['monocle_container'])
                    focused_window_index = 0
                for index, window in enumerate(windows):
                    window_info = window['windows']['elements'][0]
                    tid, pid = GetWindowThreadProcessId(window_info['hwnd'])
                    window_info['pid'] = pid

                    window_button = WindowButton(window_info, self._active_label)
                    if self._show_icon:
                        p = Process(pid)
                        exe_path = p.exe()
                        pixmap = self._get_icon_pixmap(exe_path)
                        qicon = QIcon(pixmap)
                        window_button.setIcon(qicon)
                    if index == focused_window_index:
                        window_button.update_focused()

                    self._multi_window_container_layout.addWidget(window_button)
                    self._window_buttons.append(window_button)
        except Exception:
            logging.exception('Failed to update window widget state')

    def _update_komorebi_state(self, komorebi_state: dict) -> bool:
        try:
            self._screen_hwnd = get_monitor_hwnd(int(QWidget.winId(self)))
            self._komorebi_state = komorebi_state

            if self._komorebi_state:
                self._komorebi_screen = self._komorebic.get_screen_by_hwnd(
                    self._komorebi_state, self._screen_hwnd
                )
                self._komorebi_workspaces = self._komorebic.get_workspaces(
                    self._komorebi_screen
                )
                return True
        except TypeError:
            return False

    def _clear_container_layout(self):
        for i in reversed(range(self._multi_window_container_layout.count())):
            old_workspace_widget = self._multi_window_container_layout.itemAt(
                i
            ).widget()
            self._multi_window_container_layout.removeWidget(old_workspace_widget)
            old_workspace_widget.deleteLater()

        self._window_buttons.clear()

    def _get_icon_pixmap(self, exe_path) -> QPixmap:
        # Get the icons
        icons = ExtractIconEx(exe_path, 0)
        icon = icons[0][0]
        width = height = 32

        # Create DC and bitmap and make them compatible.
        hdc = CreateDCFromHandle(GetDC(0))
        hbmp = CreateBitmap()
        hbmp.CreateCompatibleBitmap(hdc, width, height)
        hdc = hdc.CreateCompatibleDC()
        hdc.SelectObject(hbmp)

        # Draw the icon.
        DrawIconEx(hdc.GetHandleOutput(), 0, 0, icon, width, height, 0, None, 0x0003)

        # Get the icon's bits and convert to a QtGui.QImage.
        bitmapbits = hbmp.GetBitmapBits(True)
        image = QImage(
            bitmapbits, width, height, QImage.Format.Format_ARGB32_Premultiplied
        )

        # Create a QtGui.QPixmap from the QtGui.QImage.
        pixmap = QPixmap.fromImage(image).copy()

        # Destroy the icons.
        for icon_list in icons:
            for icon in icon_list:
                DestroyIcon(icon)

        return pixmap

    def _update_workspace_windows_title(self):
        for window_button in self._window_buttons:
            window_info = window_button.window_info
            hwnd = window_info['hwnd']
            title = GetWindowText(hwnd)
            window_info['title'] = title

            window_button.setText(self._active_label.format(win=window_info))
