using System.Diagnostics;
using static System.Math;
using System.Net.NetworkInformation;
using workspacer;
using workspacer.Bar;

public class Network_Widget : BarWidgetBase {
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;
    public int Interval { get; set; } = 1000;

    private double last_bytes_sent = 0;
    private double last_bytes_received = 0;
    private System.Timers.Timer _timer;

    public string get_text(double speed) {
        string size = "B";

        int i = 0;
        for (; i < 4; i++) {
            if (speed < 1024) {
                break;
            }
            speed /= 1024;
        }
        if (i == 0) {
            size = "B";
        } else if (i == 1) {
            size = "KB";
        } else if (i == 2) {
            size = "MB";
        } else if (i == 3) {
            size = "GB";
        }

        return Round(speed, 1) + " " + size;
    }

    public double get_upload_speed() {
        double upload_speed = 0;
        foreach (var i in NetworkInterface.GetAllNetworkInterfaces()) {
            upload_speed += i.GetIPv4Statistics().BytesSent;
        }
        upload_speed = (upload_speed - last_bytes_sent) / (Interval / 1000);

        last_bytes_sent = 0;
        foreach (var i in NetworkInterface.GetAllNetworkInterfaces()) {
            last_bytes_sent += i.GetIPv4Statistics().BytesSent;
        }

        return upload_speed;
    }

    public double get_download_speed() {
        double download_speed = 0;
        foreach (var i in NetworkInterface.GetAllNetworkInterfaces()) {
            download_speed += i.GetIPv4Statistics().BytesReceived;
        }
        download_speed = (download_speed - last_bytes_received) / (Interval / 1000);

        last_bytes_received = 0;
        foreach (var i in NetworkInterface.GetAllNetworkInterfaces()) {
            last_bytes_received += i.GetIPv4Statistics().BytesReceived;
        }

        return download_speed;
    }

    public override IBarWidgetPart[] GetParts() {
        double upload_speed = get_upload_speed();
        string upload_speed_text = get_text(upload_speed);
        double download_speed = get_download_speed();
        string download_speed_text = get_text(download_speed);

        System.Action part_clicked = () => Process.Start("taskmgr.exe");

        IBarWidgetPart part_upload_speed_icon = Part("", fore:ForeColor, back: BackColor, partClicked: part_clicked, fontname: FontName);
        IBarWidgetPart part_upload_speed = Part(upload_speed_text, fore: BackColor, partClicked: part_clicked, fontname: FontName);
        IBarWidgetPart part_download_speed_icon = Part("", fore:ForeColor, back: BackColor, partClicked: part_clicked, fontname: FontName);
        IBarWidgetPart part_download_speed = Part(download_speed_text, fore: BackColor, partClicked: part_clicked, fontname: FontName);

        IBarWidgetPart[] parts = {
            part_upload_speed_icon,
            part_upload_speed,
            part_download_speed_icon,
            part_download_speed,
        };

        return Parts(parts);
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}
