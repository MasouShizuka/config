from collections import deque

from core.validation.widgets.yasb.gpu import VALIDATION_SCHEMA
from core.widgets.base import BaseWidget
from PyQt6.QtWidgets import QLabel


class GpuWidget(BaseWidget):
    validation_schema = VALIDATION_SCHEMA

    def __init__(
        self,
        label: str,
        label_alt: str,
        histogram_icons: list[str],
        histogram_num_columns: int,
        update_interval: int,
        callbacks: dict[str, str],
    ):
        super().__init__(update_interval, class_name="gpu-widget")
        self._histogram_icons = histogram_icons
        self._gpu_percent_history = deque(
            [0] * histogram_num_columns,
            maxlen=histogram_num_columns,
        )

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
        active_label = self._label_alt if self._show_alt_label else self._label
        active_label_content = (
            self._label_alt_content if self._show_alt_label else self._label_content
        )
        active_label.setText(active_label_content)

        try:
            info = self._get_gpu_info()
            active_label.setText(active_label_content.format(info=info))
        except Exception:
            active_label.setText(active_label_content)

    def _get_histogram_bar(self, num, num_min, num_max):
        max_index = len(self._histogram_icons) - 1
        bar_index = int((num - num_min) / (num_max - num_min) * 10)
        bar_index = max_index if bar_index > max_index else bar_index

        return self._histogram_icons[bar_index]

    def _get_gpu_info(self) -> dict:
        GPUs_info = self._get_GPUs_info()
        num_GPU = len(GPUs_info)

        total_memory_total = 0
        for GPU_info in GPUs_info:
            total_memory_total += GPU_info["memory.total"]

        total_memory_used = 0
        for GPU_info in GPUs_info:
            total_memory_used += GPU_info["memory.used"]

        total_memory_free = 0
        for GPU_info in GPUs_info:
            total_memory_free += GPU_info["memory.free"]

        total_memory_utilization = 0
        for GPU_info in GPUs_info:
            total_memory_utilization += GPU_info["utilization.gpu"]
        current_percent = int(total_memory_utilization / num_GPU)

        cores_percent = []
        for GPU_info in GPUs_info:
            cores_percent.append(GPU_info["utilization.gpu"])

        self._gpu_percent_history.append(current_percent)

        return {
            "cores": num_GPU,
            "memory": {
                "total": total_memory_total,
                "used": total_memory_used,
                "free": total_memory_free,
            },
            "percent": {
                "core": cores_percent,
                "total": current_percent,
            },
            "histograms": {
                "gpu_percent": "".join(
                    [
                        self._get_histogram_bar(percent, 0, 100)
                        for percent in self._gpu_percent_history
                    ]
                )
                .encode("utf-8")
                .decode("unicode_escape"),
                "cores": "".join(
                    [
                        self._get_histogram_bar(percent, 0, 100)
                        for percent in cores_percent
                    ]
                )
                .encode("utf-8")
                .decode("unicode_escape"),
            },
        }

    def _get_GPUs_info(self):
        from os import linesep
        from subprocess import PIPE, Popen

        nvidia_smi = "nvidia-smi"
        try:
            p = Popen(
                [
                    nvidia_smi,
                    "--query-gpu=index,uuid,utilization.gpu,memory.total,memory.used,memory.free,driver_version,name,gpu_serial,display_active,display_mode,temperature.gpu",
                    "--format=csv,noheader,nounits",
                ],
                stdout=PIPE,
                shell=True,
            )
            stdout, stderror = p.communicate()
        except:
            return []

        output = stdout.decode("utf-8")
        lines = output.split(linesep)
        GPUs_info = []
        for line in lines:
            if line.strip():
                values = line.split(", ")
                GPU_info = {
                    "index": int(values[0]),
                    "uuid": values[1],
                    "utilization.gpu": int(values[2]),
                    "memory.total": int(values[3]),
                    "memory.used": int(values[4]),
                    "memory.free": int(values[5]),
                    "driver_version": values[6],
                    "name": values[7],
                    "gpu_serial": values[8],
                    "display_active": values[9],
                    "display_mode": values[10],
                    "temperature.gpu": int(values[11]),
                }
                GPUs_info.append(GPU_info)

        return GPUs_info
