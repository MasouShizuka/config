using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using workspacer;
using workspacer.Bar;

public class Battery_Widget : BarWidgetBase {
    public Color IconColor { get; set; } = Color.Black;
    public Color LowChargeColor { get; set; } = Color.Red;
    public Color MedChargeColor { get; set; } = Color.Yellow;
    public Color HighChargeColor { get; set; } = Color.Green;
    public bool HasBatteryWarning { get; set; } = true;
    public double LowChargeThreshold { get; set; } = 0.10;
    public double MedChargeThreshold { get; set; } = 0.50;
    public int Interval { get; set; } = 5000;
    
    private System.Timers.Timer _timer;

    public override IBarWidgetPart[] GetParts() {
        PowerStatus pwr = SystemInformation.PowerStatus;
        float currentBatteryCharge = pwr.BatteryLifePercent;

        Color charge_color = null;
        if (HasBatteryWarning) {
            if (currentBatteryCharge <= LowChargeThreshold) {
                charge_color = LowChargeColor;
            } else if (currentBatteryCharge <= MedChargeThreshold) {
                charge_color = MedChargeColor;
            } else {
                charge_color = HighChargeColor;
            }
        }

        string charge_icon = "";
        if (currentBatteryCharge >= 0.9) {
            charge_icon = "";
        } else if (currentBatteryCharge >= 0.8) {
            charge_icon = "";
        } else if (currentBatteryCharge >= 0.7) {
            charge_icon = "";
        } else if (currentBatteryCharge >= 0.6) {
            charge_icon = "";
        } else if (currentBatteryCharge >= 0.5) {
            charge_icon = "";
        } else if (currentBatteryCharge >= 0.4) {
            charge_icon = "";
        } else if (currentBatteryCharge >= 0.3) {
            charge_icon = "";
        } else if (currentBatteryCharge >= 0.2) {
            charge_icon = "";
        } else {
            charge_icon = "";
        }

        IBarWidgetPart part_icon = Part(charge_icon, fore:IconColor, back: charge_color, fontname: FontName);
        IBarWidgetPart part_battery = Part(currentBatteryCharge.ToString("#0%"), fore: charge_color, fontname: FontName);

        IBarWidgetPart[] parts = {
            part_icon,
            part_battery,
        };

        return Parts(parts);
    }

    public override void Initialize() {
        _timer = new System.Timers.Timer(Interval);
        _timer.Elapsed += (s, e) => MarkDirty();
        _timer.Enabled = true;
    }
}
