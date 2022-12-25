import logging
from time import time

from core.event_enums import KomorebiEvent
from core.event_service import EventService
from core.utils.komorebi.client import KomorebiClient
from core.utils.win32.utilities import get_monitor_hwnd
from core.validation.widgets.komorebi.refresh_window import VALIDATION_SCHEMA
from core.widgets.base import BaseWidget
from PyQt6.QtCore import pyqtSignal
from PyQt6.QtWidgets import QWidget
from win32gui import GetForegroundWindow, SetForegroundWindow

try:
    from core.utils.komorebi.event_listener import KomorebiEventListener
except ImportError:
    KomorebiEventListener = None
    logging.warning("Failed to load Komorebi Event Listener")


class RefreshWindowWidget(BaseWidget):
    k_signal_window_change = pyqtSignal(dict, dict)

    validation_schema = VALIDATION_SCHEMA
    event_listener = KomorebiEventListener

    def __init__(
        self,
        refresh_delay: int,
        min_interval: int,
        refresh_process_name_list: list[str],
    ):
        super().__init__(class_name="komorebi-refresh-window")
        self._refresh_delay = refresh_delay
        self._min_interval = min_interval
        self._last_refresh_time = 0
        self._last_focus_time = 0

        self._refresh_process_name_list = refresh_process_name_list

        self._event_service = EventService()
        self._komorebic = KomorebiClient()
        self._komorebi_screen = None
        self._komorebi_workspaces = []
        self._focused_workspace = {}

        self._register_signals_and_events()

    def _register_signals_and_events(self):
        refresh_window_event_watchlist = [
            KomorebiEvent.ToggleMonocle,
            KomorebiEvent.FocusChange,
            KomorebiEvent.CycleMoveWindow,
        ]

        self.k_signal_window_change.connect(self._on_komorebi_window_change_event)

        for event_type in refresh_window_event_watchlist:
            self._event_service.register_event(event_type, self.k_signal_window_change)

    def _on_komorebi_window_change_event(self, event: dict, state: dict):
        self._update_workspace_windows(state)

    def _update_workspace_windows(self, state: dict):
        try:
            if self._update_komorebi_state(state):
                self._focused_workspace = self._komorebic.get_focused_workspace(
                    self._komorebi_screen
                )

                if not self._focused_workspace:
                    return

                windows = self._focused_workspace["containers"]["elements"]
                focused_window_index = self._focused_workspace["containers"]["focused"]
                if self._focused_workspace["monocle_container"] is not None:
                    windows.insert(0, self._focused_workspace["monocle_container"])
                    focused_window_index = 0

                focused_window = windows[focused_window_index]
                focused_window_info = focused_window["windows"]["elements"][0]
                if focused_window_info["exe"] in self._refresh_process_name_list:
                    self._refresh_window()

                if GetForegroundWindow() != focused_window_info["hwnd"]:
                    self._focus_window(focused_window_info["hwnd"])
        except Exception:
            logging.exception("Failed to update window widget state")

    def _update_komorebi_state(self, komorebi_state: dict) -> bool:
        try:
            self._screen_hwnd = get_monitor_hwnd(int(QWidget.winId(self)))
            self._komorebi_state = komorebi_state

            focused_monitor_index = self._komorebi_state["monitors"]["focused"]
            focused_screen = self._komorebi_state["monitors"]["elements"][
                focused_monitor_index
            ]
            focused_screen_hwnd = focused_screen["id"]
            if self._screen_hwnd != focused_screen_hwnd:
                return False

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

    def _refresh_window(self):
        prev_last_refresh_time = self._last_refresh_time
        last_refresh_time = round(time() * 1000)
        if last_refresh_time - prev_last_refresh_time >= self._min_interval:
            from tkinter import Tk

            root = Tk()
            root.wm_attributes("-topmost", 1)
            root.focus_force()
            root.attributes("-alpha", 0)
            root.after(self._refresh_delay, root.destroy)
            root.mainloop()

            self._last_refresh_time = last_refresh_time

    def _focus_window(self, hwnd):
        prev_last_focus_time = self._last_focus_time
        last_focus_time = round(time() * 1000)
        if last_focus_time - prev_last_focus_time >= self._min_interval:
            SetForegroundWindow(hwnd)

            self._last_focus_time = last_focus_time
