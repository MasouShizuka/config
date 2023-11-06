local utils = require("config.utils")
local variables = require("config.variables")

return {
    -- 会使得 lsp 跳转到未打开的文件时卡死
    -- {
    --     "Bekaboo/dropbar.nvim",
    --     enabled = not variables.is_vscode,
    --     event = {
    --         "BufNewFile",
    --         "BufReadPost",
    --     },
    --     dependencies = {
    --         "nvim-tree/nvim-web-devicons",
    --     },
    --     keys = {
    --         { "<leader><tab>", function() require("dropbar.api").pick() end, desc = "Pick mode", mode = "n" },
    --     },
    --     opts = {
    --         icons = {
    --             kinds = {
    --                 symbols = variables.icons.kinds,
    --             },
    --         },
    --         menu = {
    --             entry = {
    --                 padding = {
    --                     left = 0,
    --                     right = 0,
    --                 },
    --             },
    --             keymaps = {
    --                 ["h"] = "<cmd>q!<cr><esc>",
    --                 ["q"] = "<cmd>q!<cr><esc>",
    --                 ["l"] = function()
    --                     local menu = require("dropbar.api").get_current_dropbar_menu()
    --                     if not menu then
    --                         return
    --                     end
    --                     vim.cmd.normal("w")
    --                     local cursor = vim.api.nvim_win_get_cursor(menu.win)
    --                     local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
    --                     if component then
    --                         menu:click_on(component, nil, 1, "l")
    --                     end
    --                 end,
    --                 ["o"] = function()
    --                     local menu = require("dropbar.api").get_current_dropbar_menu()
    --                     if not menu then
    --                         return
    --                     end
    --                     vim.cmd.normal("0")
    --                     local cursor = vim.api.nvim_win_get_cursor(menu.win)
    --                     local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
    --                     if component then
    --                         menu:click_on(component, nil, 1, "l")
    --                     end
    --                 end,
    --             },
    --         },
    --     },
    -- },

    {
        "rebelot/heirline.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        event = {
            "UIEnter",
        },
        opts = function()
            local herrline_conditions = require("heirline.conditions")
            local heirline_utils = require("heirline.utils")

            local colors = {
                bright_bg = heirline_utils.get_highlight("Folded").bg,
                bright_fg = heirline_utils.get_highlight("Folded").fg,
                red = heirline_utils.get_highlight("DiagnosticError").fg,
                dark_red = heirline_utils.get_highlight("DiffDelete").bg,
                green = heirline_utils.get_highlight("String").fg,
                yellow = heirline_utils.get_highlight("Type").fg,
                blue = heirline_utils.get_highlight("Function").fg,
                gray = heirline_utils.get_highlight("NonText").fg,
                orange = heirline_utils.get_highlight("Constant").fg,
                purple = heirline_utils.get_highlight("Statement").fg,
                cyan = heirline_utils.get_highlight("Special").fg,
                diag_warn = heirline_utils.get_highlight("DiagnosticWarn").fg,
                diag_error = heirline_utils.get_highlight("DiagnosticError").fg,
                diag_hint = heirline_utils.get_highlight("DiagnosticHint").fg,
                diag_info = heirline_utils.get_highlight("DiagnosticInfo").fg,
                git_del = heirline_utils.get_highlight("diffRemoved").fg,
                git_add = heirline_utils.get_highlight("diffAdded").fg,
                git_change = heirline_utils.get_highlight("diffChanged").fg,
            }
            require("heirline").load_colors(colors)

            local align = { provider = "%=" }

            local function padding_before(component, n)
                n = n or 1
                local space = { provider = string.rep(" ", n) }

                local condition = component.condition
                component.condition = nil

                return {
                    condition = condition,

                    space,
                    component,
                }
            end

            local function padding_after(component, n)
                n = n or 1
                local space = { provider = string.rep(" ", n) }

                local condition = component.condition
                component.condition = nil

                return {
                    condition = condition,

                    component,
                    space,
                }
            end

            local function surround(delimiters, color, component)
                local surrounded = heirline_utils.surround(delimiters, color, component)
                surrounded.condition = component.condition
                return surrounded
            end

            local function insert_with_child_condition(destination, ...)
                local children = { ... }
                local new = heirline_utils.clone(destination)

                for _, child in ipairs(children) do
                    local new_child = heirline_utils.clone(child)
                    table.insert(new, new_child)
                end

                local old_condition = new.condition
                local new_condition = function(self)
                    if old_condition and not old_condition(self) then
                        return false
                    end

                    for _, child in ipairs(children) do
                        if child.condition and child.condition(child) then
                            return true
                        end
                    end

                    return false
                end
                new.condition = new_condition

                return new
            end

            local function get_diagnostic_severity(severity, show_count)
                local icon, hl
                if severity == "error" then
                    icon = variables.icons.diagnostics.Error
                    hl = { fg = "diag_error" }
                elseif severity == "warn" then
                    icon = variables.icons.diagnostics.Warn
                    hl = { fg = "diag_warn" }
                elseif severity == "info" then
                    icon = variables.icons.diagnostics.Info
                    hl = { fg = "diag_info" }
                elseif severity == "hint" then
                    icon = variables.icons.diagnostics.Hint
                    hl = { fg = "diag_hint" }
                end

                return {
                    condition = function(self)
                        self.count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity:upper()] })
                        return self.count > 0
                    end,
                    provider = function(self)
                        if show_count then
                            return icon .. self.count
                        else
                            return icon
                        end
                    end,
                    hl = hl,
                }
            end

            local function get_git_status(status, show_count)
                local icon, hl
                if status == "added" then
                    icon = variables.icons.git.added
                    hl = { fg = "git_add" }
                elseif status == "changed" then
                    icon = variables.icons.git.modified
                    hl = { fg = "git_change" }
                elseif status == "removed" then
                    icon = variables.icons.git.deleted
                    hl = { fg = "git_del" }
                end

                return {
                    condition = function(self)
                        if vim.b.gitsigns_status_dict == nil then
                            return false
                        end

                        self.count = vim.b.gitsigns_status_dict[status] or 0
                        return self.count > 0
                    end,
                    provider = function(self)
                        if show_count then
                            return icon .. self.count
                        else
                            return icon
                        end
                    end,
                    hl = hl,
                }
            end

            local mode = {
                static = {
                    mode_names = {
                        n = "NORMAL",
                        no = "OP",
                        nov = "OP",
                        noV = "OP",
                        ["no\22"] = "OP",
                        niI = "NORMAL",
                        niR = "NORMAL",
                        niV = "NORMAL",
                        nt = "NORMAL",
                        ntT = "NORMAL",
                        v = "VISUAL",
                        vs = "VISUAL",
                        V = "V-LINE",
                        Vs = "V-LINE",
                        ["\22"] = "V-BLOCK",
                        ["\22s"] = "V-BLOCK",
                        s = "SELECT",
                        S = "SELECT",
                        ["\19"] = "BLOCK",
                        i = "INSERT",
                        ic = "INSERT",
                        ix = "INSERT",
                        R = "REPLACE",
                        Rc = "REPLACE",
                        Rx = "REPLACE",
                        Rv = "V-REPLACE",
                        Rvc = "V-REPLACE",
                        Rvx = "V-REPLACE",
                        c = "COMMAND",
                        cv = "COMMAND",
                        r = "ENTER",
                        rm = "MORE",
                        ["r?"] = "CONFIRM",
                        ["!"] = "SHELL",
                        t = "TERMINAL",
                    },
                    mode_colors_map = {
                        n = "green",
                        i = "blue",
                        v = "yellow",
                        V = "yellow",
                        ["\22"] = "yellow",
                        c = "purple",
                        s = "yellow",
                        S = "yellow",
                        ["\19"] = "yellow",
                        R = "red",
                        r = "red",
                        ["!"] = "green",
                        t = "blue",
                    },
                    mode_color = function(self)
                        local mode = herrline_conditions.is_active() and vim.fn.mode() or "n"
                        return self.mode_colors_map[mode]
                    end,
                },
                update = {
                    "ModeChanged",
                    callback = vim.schedule_wrap(function()
                        vim.cmd.redrawstatus()
                    end),
                    pattern = "*:*",
                },

                surround(
                    { "", "" },
                    function(self)
                        return self:mode_color()
                    end,
                    {
                        init = function(self)
                            self.mode = vim.fn.mode(1)
                        end,
                        provider = function(self)
                            return " " .. self.mode_names[self.mode]
                        end,
                        hl = { fg = heirline_utils.get_highlight("bg").fg },
                    }
                ),
            }

            local file_encoding = {
                provider = function(self)
                    local encoding = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
                    return "󰅩 " .. encoding:upper()
                end,
            }
            local file_format = {
                provider = function(self)
                    local fmt = vim.bo.fileformat
                    if fmt == "dos" then
                        return " CRLF"
                    else
                        return " LF"
                    end
                end,
            }
            local file_icon = {
                init = function(self)
                    local filename = self.filename or vim.api.nvim_buf_get_name(0)
                    local extension = vim.fn.fnamemodify(filename, ":e")
                    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
                end,
                provider = function(self)
                    return self.icon and (self.icon .. " ")
                end,
                hl = function(self)
                    return { fg = self.icon_color }
                end,
            }
            local file_modified = {
                condition = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    return vim.api.nvim_get_option_value("modified", { buf = buf })
                end,
                provider = "[+]",
                hl = { fg = "green" },
            }
            local file_name = {
                init = function(self)
                    self.max_length = 30
                    self.is_terminal = herrline_conditions.buffer_matches({ buftype = { "terminal" } })

                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    self.is_modified = self.buf and vim.api.nvim_get_option_value("modified", { buf = buf })
                end,
                provider = function(self)
                    local filename = self.filename or vim.api.nvim_buf_get_name(0)
                    if filename == "" then
                        return "[No Name]"
                    end

                    filename = vim.fn.fnamemodify(filename, ":t")
                    if self.is_terminal then
                        filename, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
                    else
                        local char_count, char_list = utils.get_char_from_string(filename)
                        if char_count > self.max_length then
                            filename = "..." .. table.concat(char_list, "", char_count - self.max_length + 1)
                        end
                    end

                    return filename
                end,
                hl = function(self)
                    local hl

                    if self.tabpage and not self.is_active then
                        return hl
                    end

                    local error = get_diagnostic_severity("error")
                    local warn = get_diagnostic_severity("warn")
                    if not self.is_modified then
                        if error.condition(self) then
                            hl = error.hl
                        elseif warn.condition(self) then
                            hl = warn.hl
                        end
                    end

                    if self.tabpage and self.is_active then
                        if hl == nil then
                            hl = { fg = heirline_utils.get_highlight("TabLineSel").bg }
                        end
                        hl["bold"] = true
                    end

                    return hl
                end,
            }
            local file_readonly = {
                condition = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = buf })
                    local readonly = vim.api.nvim_get_option_value("readonly", { buf = buf })
                    return not modifiable or readonly
                end,
                provider = function(self)
                    if vim.api.nvim_get_option_value("buftype", { buf = self.buf }) == "terminal" then
                        return " "
                    else
                        return " "
                    end
                end,
                hl = { fg = "orange" },
            }
            local file_size = {
                provider = function(self)
                    local filename = self.filename or vim.api.nvim_buf_get_name(0)
                    local suffix = { "B", "K", "M", "G", "T", "P", "E" }
                    local fsize = vim.fn.getfsize(filename)
                    fsize = (fsize < 0 and 0) or fsize
                    if fsize < 1024 then
                        return fsize .. suffix[1]
                    end
                    local i = math.floor((math.log(fsize) / math.log(1024)))
                    return string.format("%.1f%s", fsize / (1024 ^ i), suffix[i + 1])
                end,
            }

            local ruler = {
                padding_after({
                    condition = function(self)
                        local mode = vim.fn.mode()
                        self.is_v = mode:find("v")
                        self.is_V = mode:find("V")
                        return self.is_v or self.is_V
                    end,
                    provider = function(self)
                        if self.is_v then
                            return ("󰈍 %s"):format(vim.fn.wordcount().visual_chars)
                        else
                            local visual_start = vim.fn.line("v")
                            local visual_end = vim.fn.line(".")
                            local lines = visual_start <= visual_end and visual_end - visual_start + 1 or visual_start - visual_end + 1
                            return (" %s"):format(lines)
                        end
                    end,
                }),
                {
                    provider = " %l:%c %P",
                },
            }
            local scrollbar = {
                static = {
                    sbar = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" },
                },
                init = function(self)
                    self.row = vim.api.nvim_win_get_cursor(0)[1]
                    self.line_count = vim.api.nvim_buf_line_count(0)
                end,
                provider = function(self)
                    local i = math.floor((self.row - 1) / self.line_count * #self.sbar) + 1
                    return string.rep(self.sbar[i], 2)
                end,
                hl = { fg = "blue", bg = "gray" },
            }

            local lsp = {
                condition = herrline_conditions.lsp_attached,
                provider  = function(self)
                    local names = {}
                    for _, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
                        table.insert(names, server.name)
                    end
                    return " " .. table.concat(names, ",")
                end,
                hl        = { fg = "green" },
                update    = { "LspAttach", "LspDetach" },
            }
            local navic = {
                static = {
                    type_hl = {
                        File = "Structure",
                        Module = "Structure",
                        Namespace = "Structure",
                        Package = "Structure",
                        Class = "Structure",
                        Method = "Function",
                        Property = "Identifier",
                        Field = "Identifier",
                        Constructor = "Structure",
                        Enum = "Type",
                        Interface = "Type",
                        Function = "Function",
                        Variable = "Identifier",
                        Constant = "Constant",
                        String = "String",
                        Number = "Number",
                        Boolean = "Boolean",
                        Array = "Structure",
                        Object = "Structure",
                        Key = "Identifier",
                        Null = "Special",
                        EnumMember = "Identifier",
                        Struct = "Structure",
                        Event = "Type",
                        Operator = "Operator",
                        TypeParameter = "Type",
                    },
                },
                init = function(self)
                    local children = { { provider = " " } }

                    local filename = self.filename or vim.api.nvim_buf_get_name(0)
                    filename = vim.fn.fnamemodify(filename, ":.")
                    if variables.is_windows then
                        filename = filename:gsub("\\", "/")
                    end
                    for token in filename:gmatch("([^/]+)/?") do
                        table.insert(children, {
                            provider = token,
                        })
                        table.insert(children, {
                            provider = "  ",
                        })
                    end
                    table.remove(children, #children)
                    table.insert(children, #children, file_icon)

                    local is_navic_available, navic = pcall(require, "nvim-navic")
                    if is_navic_available then
                        local data = navic.get_data() or {}
                        for _, d in ipairs(data) do
                            local child = {
                                {
                                    provider = "  ",
                                },
                                {
                                    provider = d.icon,
                                    hl = self.type_hl[d.type],
                                },
                                {
                                    provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ""),
                                },
                            }
                            table.insert(children, child)
                        end
                    end

                    self.child = self:new(children, 1)
                end,
                provider = function(self)
                    return self.child:eval()
                end,
                update = "CursorMoved",
            }

            local diagnostic = insert_with_child_condition({
                    condition = function(self)
                        local modified = vim.api.nvim_get_option_value("modified", { buf = self.buf })
                        return not modified
                    end,
                    update = { "DiagnosticChanged", "BufEnter" },
                },
                padding_before(get_diagnostic_severity("error", true)),
                padding_before(get_diagnostic_severity("warn", true)),
                padding_before(get_diagnostic_severity("info", true)),
                padding_before(get_diagnostic_severity("hint", true))
            )

            local lsp_diagnostic = insert_with_child_condition({}, lsp, diagnostic)

            local git_branch = {
                condition = function(self)
                    if not herrline_conditions.is_git_repo then
                        return false
                    end

                    self.status_dict = vim.b.gitsigns_status_dict
                    return self.status_dict and true or false
                end,
                provider = function(self)
                    return " " .. self.status_dict.head
                end,
                hl = { fg = "orange" },
            }

            local git_status = insert_with_child_condition(
                {},
                padding_before(get_git_status("added", true)),
                padding_before(get_git_status("changed", true)),
                padding_before(get_git_status("removed", true))
            )

            local git = insert_with_child_condition({}, git_branch, git_status)

            local macro = {
                condition = function(self)
                    return vim.fn.reg_recording() ~= ""
                end,
                update = { "RecordingEnter", "RecordingLeave" },

                {
                    provider = "󰻃 ",
                    hl = { fg = "orange", bold = true },
                },
                surround({ "[", "]" }, nil, {
                    provider = function(self)
                        return vim.fn.reg_recording()
                    end,
                    hl = { fg = "green", bold = true },
                }),
            }

            local lazy = {
                condition = require("lazy.status").has_updates,
                provider = function(self)
                    return require("lazy.status").updates()
                end,
                hl = { fg = "#ff9e64" },
                update = { "User", pattern = "LazyUpdate" },
                on_click = {
                    callback = function()
                        require("lazy").update()
                    end,
                    name = "update_plugins",
                },
            }

            local tabline_offset = {
                condition = function(self)
                    self.title = "Explorer"
                    self.win = vim.api.nvim_tabpage_list_wins(0)[1]
                    self.buf = vim.api.nvim_win_get_buf(self.win)
                    return variables.is_in_toggle_filetype_list(vim.bo[self.buf].filetype, variables.toggle_filetype_list1)
                end,
                provider = function(self)
                    local width = vim.api.nvim_win_get_width(self.win)
                    local pad = math.ceil((width - #self.title) / 2)
                    return string.rep(" ", pad) .. self.title .. string.rep(" ", pad)
                end,
            }

            local tab = {
                init = function(self)
                    self.win = vim.api.nvim_tabpage_get_win(self.tabpage)
                    self.buf = vim.api.nvim_win_get_buf(self.win)
                    self.filename = vim.api.nvim_buf_get_name(self.buf)
                end,
                on_click = {
                    callback = function(_, minwid, _, button)
                        if (button == "m") then
                            vim.schedule(function()
                                vim.api.nvim_command("tabclose " .. minwid)
                                vim.cmd.redrawtabline()
                            end)
                        else
                            vim.api.nvim_command(minwid .. "tabnext")
                        end
                    end,
                    minwid = function(self)
                        return self.tabnr
                    end,
                    name = "heirline_tabline_buffer_callback",
                },

                file_icon,
                heirline_utils.insert(
                    file_name,
                    padding_before(
                        insert_with_child_condition(
                            {
                                condition = function(self)
                                    local modified = vim.api.nvim_get_option_value("modified", { buf = self.buf })
                                    return self.is_active and not modified
                                end,
                                update = { "DiagnosticChanged", "BufEnter" },
                            },
                            {
                                condition = function(self)
                                    self.diagnostic_count = #vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.WARN } })
                                    return self.diagnostic_count > 0
                                end,
                                provider = function(self)
                                    return self.diagnostic_count
                                end,
                            }
                        )
                    )
                ),
                padding_before(
                    insert_with_child_condition({
                            condition = function(self)
                                return self.is_active
                            end,
                        },
                        file_modified,
                        file_readonly
                    )
                ),
                padding_before({
                    provider = "",
                    hl = { fg = "gray" },
                    on_click = {
                        callback = function(_, minwid)
                            vim.schedule(function()
                                vim.api.nvim_command("tabclose " .. minwid)
                                vim.cmd.redrawtabline()
                            end)
                        end,
                        minwid = function(self)
                            return self.tabnr
                        end,
                        name = "heirline_tabline_close_tab_callback",
                    },
                }),
            }

            local function make_tablist(tab_component, left_trunc, right_trunc)
                left_trunc = left_trunc or { provider = " " }
                right_trunc = right_trunc or { provider = " " }

                left_trunc.on_click = {
                    callback = function(self)
                        self._buflist[1]._cur_page = self._cur_page - 1
                        self._buflist[1]._force_page = true
                        vim.cmd("redrawtabline")
                    end,
                    name = "Heirline_tabline_prev",
                }
                right_trunc.on_click = {
                    callback = function(self)
                        self._buflist[1]._cur_page = self._cur_page + 1
                        self._buflist[1]._force_page = true
                        vim.cmd("redrawtabline")
                    end,
                    name = "Heirline_tabline_next",
                }

                local tablist = {
                    static = {
                        _left_trunc = left_trunc,
                        _right_trunc = right_trunc,
                        _cur_page = 1,
                        _force_page = false,
                    },
                    init = function(self)
                        if vim.tbl_isempty(self._buflist) then
                            table.insert(self._buflist, self)
                        end
                        if not self.left_trunc then
                            self.left_trunc = self:new(self._left_trunc)
                        end
                        if not self.right_trunc then
                            self.right_trunc = self:new(self._right_trunc)
                        end

                        if not self._once then
                            vim.api.nvim_create_autocmd({ "TabEnter" }, {
                                callback = function()
                                    self._force_page = false
                                end,
                                desc = "Heirline release lock for next/prev buttons",
                            })
                            self._once = true
                        end

                        self.active_child = false

                        local tabpages = vim.tbl_filter(function(tabnr)
                            return vim.api.nvim_tabpage_is_valid(tabnr)
                        end, vim.api.nvim_list_tabpages())

                        for i, tabpage in ipairs(tabpages) do
                            local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
                            local child = self[i]
                            if not (child and child.tabpage == tabpage) then
                                self[i] = self:new(tab_component, i)
                                child = self[i]
                                child.tabnr = tabnr
                                child.tabpage = tabpage
                            end

                            if tabpage == vim.api.nvim_get_current_tabpage() then
                                child.is_active = true
                                self.active_child = i
                            else
                                child.is_active = false
                            end
                        end
                        if #self > #tabpages then
                            for i = #tabpages + 1, #self do
                                self[i] = nil
                            end
                        end
                    end,
                }
                return tablist
            end

            local tablist = make_tablist(
                surround({ " ", " " }, nil, tab),
                { provider = " ", hl = { fg = "gray" } },
                { provider = " ", hl = { fg = "gray" } }
            )

            --- A helper function for decoding statuscolumn click events with mouse click pressed, modifier keys, as well as which signcolumn sign was clicked if any
            ---@param self any the self parameter from Heirline component on_click.callback function call
            ---@param minwid any the minwid parameter from Heirline component on_click.callback function call
            ---@param clicks any the clicks parameter from Heirline component on_click.callback function call
            ---@param button any the button parameter from Heirline component on_click.callback function call
            ---@param mods any the button parameter from Heirline component on_click.callback function call
            ---@return table # the argument table with the decoded mouse information and signcolumn signs information
            -- @usage local heirline_component = { on_click = { callback = function(...) local args = require("astronvim.utils.status").utils.statuscolumn_clickargs(...) end } }
            local function statuscolumn_clickargs(self, minwid, clicks, button, mods)
                local args = {
                    minwid = minwid,
                    clicks = clicks,
                    button = button,
                    mods = mods,
                    mousepos = vim.fn.getmousepos(),
                }
                if not self.signs then
                    self.signs = {}
                end
                args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
                if args.char == " " then
                    args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
                end
                args.sign = self.signs[args.char]
                if not args.sign then -- update signs if not found on first click
                    for _, sign_def in ipairs(vim.fn.sign_getdefined()) do
                        if sign_def.text then
                            self.signs[sign_def.text:gsub("%s", "")] = sign_def
                        end
                    end
                    args.sign = self.signs[args.char]
                end
                vim.api.nvim_set_current_win(args.mousepos.winid)
                vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
                return args
            end

            local ffi = require("ffi")
            ffi.cdef [[
                typedef struct {} Error;
                typedef struct {} win_T;
                typedef struct {
                    int start;  // line number where deepest fold starts
                    int level;  // fold level, when zero other fields are N/A
                    int llevel; // lowest level that starts in v:lnum
                    int lines;  // number of lines from v:lnum to end of closed fold
                } foldinfo_T;
                foldinfo_T fold_info(win_T* wp, int lnum);
                win_T *find_window_by_handle(int Window, Error *err);
                int compute_foldcolumn(win_T *wp, int col);
            ]]
            local fold = {
                condition = function(self)
                    return vim.opt.foldcolumn:get() ~= "0"
                end,
                provider = function(self)
                    local fillchars = vim.opt.fillchars:get()
                    local foldopen = fillchars.foldopen or variables.icons.fold.FoldOpened
                    local foldclosed = fillchars.foldclose or variables.icons.fold.FoldClosed
                    local foldsep = fillchars.foldsep or variables.icons.fold.FoldSeparator

                    -- move to M.fold_indicator
                    local wp = ffi.C.find_window_by_handle(0, ffi.new("Error")) -- get window handler
                    local width = ffi.C.compute_foldcolumn(wp, 0)               -- get foldcolumn width
                    -- get fold info of current line
                    local foldinfo = width > 0 and ffi.C.fold_info(wp, vim.v.lnum) or { start = 0, level = 0, llevel = 0, lines = 0 }

                    local str = ""
                    if width ~= 0 then
                        str = vim.v.relnum > 0 and "%#FoldColumn#" or "%#CursorLineFold#"
                        if foldinfo.level == 0 then
                            str = str .. (" "):rep(width)
                        else
                            local closed = foldinfo.lines > 0
                            local first_level = foldinfo.level - width - (closed and 1 or 0) + 1
                            if first_level < 1 then first_level = 1 end

                            for col = 1, width do
                                str = str
                                    .. (
                                        (vim.v.virtnum ~= 0 and foldsep)
                                        or ((closed and (col == foldinfo.level or col == width)) and foldclosed)
                                        or ((foldinfo.start == vim.v.lnum and first_level + col > foldinfo.llevel) and foldopen)
                                        or foldsep
                                    )
                                if col == foldinfo.level then
                                    str = str .. (" "):rep(width - col)
                                    break
                                end
                            end
                        end
                    end

                    return str .. "%*"
                end,
                on_click = {
                    callback = function(...)
                        local char = statuscolumn_clickargs(...).char
                        local fillchars = vim.opt_local.fillchars:get()
                        if char == (fillchars.foldopen or variables.icons.fold.FoldOpened) then
                            vim.cmd("norm! zc")
                        elseif char == (fillchars.foldcolse or variables.icons.fold.FoldClosed) then
                            vim.cmd("norm! zo")
                        end
                    end,
                    name = "fold_click",
                },
            }

            local number = {
                condition = function(self)
                    self.number, self.relativenumber = vim.opt.number:get(), vim.opt.relativenumber:get()
                    return self.number or self.relativenumber
                end,
                provider = function(self)
                    local lnum, relnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
                    local number, relativenumber = self.number, self.relativenumber
                    local signs = vim.opt.signcolumn:get():find("nu")
                        and vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), { group = "*", lnum = lnum })[1].signs

                    local str
                    if virtnum ~= 0 then
                        str = "%="
                    elseif signs and #signs > 0 then
                        local sign = vim.fn.sign_getdefined(signs[1].name)[1]
                        str = "%=%#" .. sign.texthl .. "#" .. sign.text .. "%*"
                    elseif not number and not relativenumber then
                        str = "%="
                    else
                        local cur = relativenumber and (relnum > 0 and relnum or (number and lnum or 0)) or lnum
                        str = "%=" .. cur
                    end

                    return str .. " "
                end,
                on_click = {
                    callback = function(...)
                        local args = statuscolumn_clickargs(...)
                        if args.mods:find("c") then
                            local dap_avail, dap = pcall(require, "dap")
                            if dap_avail then
                                vim.schedule(dap.toggle_breakpoint)
                            end
                        end
                    end,
                    name = "line_click",
                },
            }

            local signcolumn = {
                condition = function(self)
                    return vim.opt.signcolumn:get() ~= "no"
                end,
                provider = function(self)
                    return "%s"
                end,
                on_click = {
                    callback = function(...)
                        local args = statuscolumn_clickargs(...)

                        local sign_handlers = {}
                        -- gitsigns handlers
                        local gitsigns = function(_)
                            local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
                            if gitsigns_avail then
                                vim.schedule(gitsigns.preview_hunk)
                            end
                        end
                        for _, sign in ipairs { "Topdelete", "Untracked", "Add", "Changedelete", "Delete" } do
                            local name = "GitSigns" .. sign
                            if not sign_handlers[name] then
                                sign_handlers[name] = gitsigns
                            end
                        end
                        -- diagnostic handlers
                        local diagnostics = function(args)
                            if args.mods:find "c" then
                                vim.schedule(vim.lsp.buf.code_action)
                            else
                                vim.schedule(vim.diagnostic.open_float)
                            end
                        end
                        for _, sign in ipairs { "Error", "Hint", "Info", "Warn" } do
                            local name = "DiagnosticSign" .. sign
                            if not sign_handlers[name] then
                                sign_handlers[name] = diagnostics
                            end
                        end
                        -- DAP handlers
                        local dap_breakpoint = function(_)
                            local dap_avail, dap = pcall(require, "dap")
                            if dap_avail then
                                vim.schedule(dap.toggle_breakpoint)
                            end
                        end
                        for _, sign in ipairs { "", "Rejected", "Condition" } do
                            local name = "DapBreakpoint" .. sign
                            if not sign_handlers[name] then
                                sign_handlers[name] = dap_breakpoint
                            end
                        end

                        if args.sign and args.sign.name and sign_handlers[args.sign.name] then
                            sign_handlers[args.sign.name](args)
                        end
                    end,
                    name = "sign_click",
                },
            }

            local terminal_statusline = {
                condition = function()
                    return herrline_conditions.buffer_matches({ buftype = { "terminal" } })
                end,

                padding_after(mode, 2),
                align,
            }

            local special_statusline = {
                condition = function()
                    return herrline_conditions.buffer_matches({
                        buftype = { "nofile", "prompt", "help", "quickfix" },
                        filetype = { "^git.*", "fugitive" },
                    })
                end,

                padding_after(mode, 2),
                align,
                padding_before(lazy, 2),
                padding_before(ruler, 2),
                padding_before(scrollbar),
            }

            local default_statusline = {
                padding_after(mode, 2),
                padding_after(macro, 2),
                padding_after(insert_with_child_condition({ flexible = 2 }, git, git_status), 2),
                padding_after(insert_with_child_condition({ flexible = 1 }, lsp_diagnostic, diagnostic), 2),
                padding_after(file_size, 2),
                align,
                padding_before(lazy, 2),
                padding_before(file_encoding, 2),
                padding_before(file_format, 2),
                padding_before(ruler, 2),
                padding_before(scrollbar),
            }

            return {
                statusline = {
                    hl = { bg = heirline_utils.get_highlight("bg_statusline").fg },
                    fallthrough = false,

                    terminal_statusline,
                    special_statusline,
                    default_statusline,
                },
                winbar = { navic },
                tabline = {
                    tabline_offset,
                    tablist,
                },
                statuscolumn = {
                    fold,
                    signcolumn,
                    align,
                    number,
                },
                opts = {
                    disable_winbar_cb = function(args)
                        if herrline_conditions.buffer_matches({
                                buftype = { "nofile", "prompt", "help", "quickfix" },
                                filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
                            }, args.buf) then
                            return true
                        end

                        local is_navic_available, navic = pcall(require, "nvim-navic")
                        local is_available = is_navic_available and navic.is_available()
                        return not is_available
                    end,
                },
            }
        end,
    },

    {
        "RRethy/vim-illuminate",
        config = function(_, opts)
            require("illuminate").configure(opts)
        end,
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        keys = {
            { "<f7>",   function() require("illuminate").goto_next_reference(false) end, desc = "Go to next reference",     mode = "n" },
            { "<s-f7>", function() require("illuminate").goto_prev_reference(false) end, desc = "Go to previous reference", mode = "n" },
        },
        opts = {
            filetypes_denylist = variables.skip_filetype_list3,
        },
    },

    {
        "SmiteshP/nvim-navic",
        enabled = not variables.is_vscode,
        init = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local buffer = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client.supports_method("textDocument/documentSymbol") then
                        require("nvim-navic").attach(client, buffer)
                    end
                end,
            })
        end,
        lazy = true,
        opts = {
            icons = variables.icons.kinds,
            lazy_update_content = true,
        },
    },
}
