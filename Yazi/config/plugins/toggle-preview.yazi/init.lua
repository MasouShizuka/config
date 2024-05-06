local preview_layout = {
    -- normal
    Manager.layout,
    -- maximize
    function(self, area)
        self.area = area

        return ui.Layout()
            :direction(ui.Layout.HORIZONTAL)
            :constraints({
                ui.Constraint.Percentage(0),
                ui.Constraint.Percentage(0),
                ui.Constraint.Percentage(100),
            })
            :split(area)
    end,
    -- hide
    function(self, area)
        self.area = area

        local all = MANAGER.ratio.parent + MANAGER.ratio.current
        return ui.Layout()
            :direction(ui.Layout.HORIZONTAL)
            :constraints({
                ui.Constraint.Ratio(MANAGER.ratio.parent, all),
                ui.Constraint.Ratio(MANAGER.ratio.current, all),
                ui.Constraint.Min(1),
            })
            :split(area)
    end,
}

local function entry(st)
    if st.status == nil then
        st.status = 1
    end

    st.status = (st.status) % 3 + 1
    Manager.layout = preview_layout[st.status]

    ya.app_emit("resize", {})
end

return { entry = entry }
