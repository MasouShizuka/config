using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using workspacer;
using workspacer.Bar;

public class Text_Widget : BarWidgetBase {
    public Color ForeColor { get; set; } = null;
    public Color BackColor { get; set; } = null;

    private string _text;

    public Text_Widget(string text) {
        _text = text;
    }

    public override IBarWidgetPart[] GetParts() {
        return Parts(Part(_text, fore: ForeColor, back: BackColor, fontname: FontName));
    }

    public override void Initialize() {}
}
