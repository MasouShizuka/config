local buftype = require("utils.buftype")
local colors = require("utils.colors")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local format = require("utils.format")
local icons = require("utils.icons")
local lint = require("utils.lint")
local lsp = require("utils.lsp")
local utils = require("utils")

return {
    {
        "rebelot/heirline.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        event = {
            "UIEnter",
        },
        opts = function()
            local herrline_conditions = require("heirline.conditions")
            local heirline_utils = require("heirline.utils")

            local heirline_colors = {}
            for _, name in ipairs(vim.tbl_values(colors)) do
                heirline_colors[name] = heirline_utils.get_highlight(name).fg
            end
            require("heirline").load_colors(heirline_colors)

            local align = { provider = "%=" }

            local function padding_before(component, n)
                n = n or 1
                local space = { provider = string.rep(" ", n) }

                return {
                    condition = component.condition,

                    space,
                    component,
                }
            end

            local function padding_after(component, n)
                n = n or 1
                local space = { provider = string.rep(" ", n) }

                return {
                    condition = component.condition,

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
                    new[#new + 1] = new_child
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
                severity = severity:upper()

                local icon, hl
                if severity == "ERROR" then
                    icon = icons.diagnostics.Error
                    hl = { fg = colors.red }
                elseif severity == "WARN" then
                    icon = icons.diagnostics.Warn
                    hl = { fg = colors.yellow }
                elseif severity == "INFO" then
                    icon = icons.diagnostics.Info
                    hl = { fg = colors.blue }
                elseif severity == "HINT" then
                    icon = icons.diagnostics.Hint
                    hl = { fg = colors.cyan }
                end

                return {
                    condition = function(self)
                        self.count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity] })
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
                status = status:lower()

                local icon, hl
                if status == "added" then
                    icon = icons.git.added
                    hl = { fg = colors.git_add }
                elseif status == "changed" then
                    icon = icons.git.modified
                    hl = { fg = colors.git_change }
                elseif status == "removed" then
                    icon = icons.git.deleted
                    hl = { fg = colors.git_delete }
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
                        n = colors.green,
                        i = colors.blue,
                        v = colors.yellow,
                        V = colors.yellow,
                        ["\22"] = colors.yellow,
                        c = colors.purple,
                        s = colors.yellow,
                        S = colors.yellow,
                        ["\19"] = colors.yellow,
                        R = colors.red,
                        r = colors.red,
                        ["!"] = colors.green,
                        t = colors.blue,
                    },
                    mode_color = function(self)
                        local mode = herrline_conditions.is_active() and vim.fn.mode() or "n"
                        return self.mode_colors_map[mode]
                    end,
                },
                update = {
                    "ModeChanged",
                    callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
                    pattern = "*:*",
                },

                surround(
                    { icons.surround.left_half_circle_thick, icons.surround.right_half_circle_thick },
                    function(self) return self:mode_color() end,
                    {
                        init = function(self)
                            self.mode = vim.fn.mode(1)
                        end,
                        provider = function(self)
                            return icons.misc.circle .. self.mode_names[self.mode]
                        end,
                        hl = { fg = colors.black },
                    }
                ),
            }

            local file_encoding = {
                provider = function(self)
                    local fileencoding = vim.api.nvim_get_option_value("fileencoding", { scope = "local" })
                    local encoding = vim.api.nvim_get_option_value("encoding", { scope = "local" })
                    local file_encoding = fileencoding ~= "" and fileencoding or encoding
                    return icons.misc.code_braces .. file_encoding:upper()
                end,
                update = { "BufEnter", "OptionSet" },
            }

            local file_format = {
                provider = function(self)
                    local fileformat = vim.api.nvim_get_option_value("fileformat", { scope = "local" })
                    if fileformat == "dos" then
                        return icons.platforms.windows .. "CRLF"
                    else
                        return icons.platforms.linux .. "LF"
                    end
                end,
                update = { "BufEnter", "OptionSet" },
            }

            local file_icon = {
                init = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    local filename = self.filename or vim.api.nvim_buf_get_name(buf)
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

            local file_indent = {
                init = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    local expandtab = vim.api.nvim_get_option_value("expandtab", { buf = buf })
                    if expandtab then
                        self.icon = icons.misc.bottom_square_bracket
                    else
                        self.icon = icons.misc.tab
                    end
                    self.tabstop = vim.api.nvim_get_option_value("tabstop", { buf = buf })
                end,
                provider = function(self)
                    return self.icon .. self.tabstop
                end,
                update = { "BufEnter", "OptionSet" },
            }

            local file_modified = {
                condition = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    return vim.api.nvim_get_option_value("modified", { buf = buf })
                end,
                provider = icons.dap.Breakpoint,
                hl = { fg = colors.green },
                update = "BufModifiedSet",
            }

            local file_name = {
                init = function(self)
                    self.max_length = 30
                end,
                provider = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    local filename = self.filename or vim.api.nvim_buf_get_name(buf)

                    if filename == "" then
                        return "[No Name]"
                    end

                    filename = vim.fn.fnamemodify(filename, ":t")

                    if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal" then
                        filename, _ = vim.api.nvim_buf_get_name(buf):gsub(".*:", "")
                    else
                        local char_list = utils.get_char_from_string(filename)
                        local char_count = #char_list
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
                    if error.condition(self) then
                        hl = error.hl
                    elseif warn.condition(self) then
                        hl = warn.hl
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
                        return icons.misc.terminal
                    else
                        return icons.misc.lock
                    end
                end,
                hl = { fg = colors.orange },
            }

            local file_size = {
                provider = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    local filename = self.filename or vim.api.nvim_buf_get_name(buf)
                    local suffix = { "B", "K", "M", "G", "T", "P", "E" }
                    local fsize = vim.fn.getfsize(filename)
                    fsize = (fsize < 0 and 0) or fsize
                    if fsize < 1024 then
                        return fsize .. suffix[1]
                    end
                    local i = math.floor((math.log(fsize) / math.log(1024)))
                    return string.format("%.1f%s", fsize / (1024 ^ i), suffix[i + 1])
                end,
                update = { "BufEnter", "BufWrite" },
            }

            local ruler = {
                update = { "CursorMoved", "ModeChanged" },

                padding_after({
                    condition = function(self)
                        local mode = vim.fn.mode()
                        self.is_mode_v = mode:find("v")
                        self.is_mode_V = mode:find("V")
                        return self.is_mode_v or self.is_mode_V
                    end,
                    provider = function(self)
                        if self.is_mode_v then
                            return string.format("%s%s", icons.misc.order_alphabetical_ascending, vim.fn.wordcount().visual_chars)
                        elseif self.is_mode_V then
                            local visual_start = vim.fn.line("v")
                            local visual_end = vim.fn.line(".")
                            local lines = visual_start <= visual_end and visual_end - visual_start + 1 or visual_start - visual_end + 1
                            return string.format("%s %s", icons.misc.line_number, lines)
                        end

                        return ""
                    end,
                }),
                {
                    provider = icons.misc.text .. "%l:%c %P",
                },
            }

            local scrollbar = {
                static = {
                    sbar = {
                        icons.misc.horizontal_one_eighth_block_2,
                        icons.misc.horizontal_one_eighth_block_3,
                        icons.misc.horizontal_one_eighth_block_4,
                        icons.misc.horizontal_one_eighth_block_5,
                        icons.misc.horizontal_one_eighth_block_6,
                        icons.misc.horizontal_one_eighth_block_7,
                    },
                },
                init = function(self)
                    self.row = vim.api.nvim_win_get_cursor(0)[1]
                    self.line_count = vim.api.nvim_buf_line_count(0)
                end,
                provider = function(self)
                    local i = math.floor((self.row - 1) / self.line_count * #self.sbar) + 1
                    return self.sbar[i]:rep(2)
                end,
                hl = { fg = colors.blue, bg = colors.gray },
                update = "CursorMoved",
            }

            local python_venv = {
                condition = function(self)
                    return utils.is_available("venv-selector.nvim") and package.loaded["venv-selector"] and vim.api.nvim_get_option_value("filetype", { scope = "local" }) == "python"
                end,
                provider = function(self)
                    local venv_name = "base"
                    local active_venv = require("venv-selector").python()
                    if active_venv ~= nil and active_venv:find("envs") then
                        venv_name = vim.fn.fnamemodify(active_venv, ":h:t")
                    end
                    return icons.languages.python .. venv_name
                end,
                hl = { fg = colors.green },
                on_click = {
                    callback = function()
                        require("venv-selector").open()
                    end,
                    name = "heirline_statusline_venv_selector",
                },
            }

            local lsp_server = {
                provider = function(self)
                    local names = {}
                    for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                        names[#names + 1] = server.name
                    end
                    return icons.misc.gear .. table.concat(names, ",")
                end,
                hl = { fg = colors.green },
                update = { "LspAttach", "LspDetach" },
            }

            local lsp_info = heirline_utils.insert(
                { condition = herrline_conditions.lsp_attached },
                padding_after(python_venv),
                lsp_server
            )

            local linter = {
                condition = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    self.ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                    return utils.is_available("nvim-lint") and package.loaded["lint"] and vim.tbl_contains(lint.lint_filetype_list, self.ft)
                end,
                provider = function(self)
                    local nvim_lint = require("lint")

                    local icon
                    if #nvim_lint.get_running() == 0 then
                        icon = icons.misc.progress_check
                    else
                        icon = icons.misc.magnify_scan
                    end

                    local names = {}
                    for _, linter in ipairs(nvim_lint._resolve_linter_by_ft(self.ft)) do
                        names[#names + 1] = linter
                    end

                    return icon .. table.concat(names, ",")
                end,
                hl = { fg = colors.red },
            }

            local formatter = {
                condition = function(self)
                    local buf = self.buf or vim.api.nvim_get_current_buf()
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                    return utils.is_available("conform.nvim") and package.loaded["conform"] and vim.tbl_contains(format.format_filetype_list, ft)
                end,
                provider = function(self)
                    local names = {}
                    for _, formatter in ipairs(require("conform").list_formatters(0)) do
                        names[#names + 1] = formatter.name
                    end
                    return icons.misc.format_list_text .. table.concat(names, ",")
                end,
                hl = { fg = colors.yellow },
                update = "BufEnter",
            }

            local navic = {
                condition = function(self)
                    return utils.is_available("nvim-navic") and package.loaded["nvim-navic"]
                end,
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
                    local separator = " " .. icons.fold.FoldClosed .. " "

                    local children = { { provider = " " } }

                    local filename = self.filename or vim.api.nvim_buf_get_name(0)
                    filename = vim.fn.fnamemodify(filename, ":.")
                    if environment.is_windows then
                        filename = filename:gsub("\\", "/")
                    end
                    for token in filename:gmatch("([^/]+)/?") do
                        children[#children + 1] = {
                            provider = token,
                        }
                        children[#children + 1] = {
                            provider = separator,
                        }
                    end
                    table.remove(children, #children)
                    table.insert(children, #children, file_icon)

                    local is_navic_available, navic = pcall(require, "nvim-navic")
                    local is_available = is_navic_available and navic.is_available()
                    if is_available then
                        local data = navic.get_data() or {}
                        for _, d in ipairs(data) do
                            local child = {
                                {
                                    provider = separator,
                                },
                                {
                                    provider = d.icon,
                                    hl = self.type_hl[d.type],
                                },
                                {
                                    provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ""),
                                },
                            }
                            children[#children + 1] = child
                        end
                    end

                    self.child = self:new(children, 1)
                end,
                provider = function(self)
                    return self.child:eval()
                end,
                update = "CursorMoved",
            }

            local diagnostic = insert_with_child_condition(
                { update = { "BufEnter", "DiagnosticChanged" } },
                padding_before(get_diagnostic_severity("error", true)),
                padding_before(get_diagnostic_severity("warn", true)),
                padding_before(get_diagnostic_severity("info", true)),
                padding_before(get_diagnostic_severity("hint", true))
            )

            local git_branch = {
                condition = function(self)
                    if not herrline_conditions.is_git_repo then
                        return false
                    end

                    self.status_dict = vim.b.gitsigns_status_dict
                    return self.status_dict and true or false
                end,
                provider = function(self)
                    return icons.git.branch .. self.status_dict.head
                end,
                hl = { fg = colors.orange },
            }

            local git_status = insert_with_child_condition(
                {},
                padding_before(get_git_status("added", true)),
                padding_before(get_git_status("changed", true)),
                padding_before(get_git_status("removed", true))
            )

            local dap = {
                condition = function(self)
                    if not (utils.is_available("nvim-dap") and package.loaded["dap"]) then
                        return false
                    end

                    self.dap = require("dap")
                    return self.dap.session() ~= nil
                end,
                provider = function(self)
                    return icons.misc.bug .. self.dap.status()
                end,
                hl = colors.blue,
            }

            local search_count = {
                condition = function(self)
                    if vim.v.hlsearch == 0 then
                        return false
                    end

                    local ok, search = pcall(vim.fn.searchcount)
                    if ok and type(search) == "table" and search.total then
                        self.search = search
                        return true
                    end

                    return false
                end,
                provider = function(self)
                    local search = self.search
                    return string.format(
                        "[%s%d/%s%d]",
                        search.current > search.maxcount and ">" or "",
                        math.min(search.current, search.maxcount),
                        search.incomplete == 2 and ">" or "",
                        math.min(search.total, search.maxcount)
                    )
                end,
                hl = { fg = colors.yellow },
            }

            local macro = {
                condition = function(self)
                    return vim.fn.reg_recording() ~= ""
                end,
                update = { "RecordingEnter", "RecordingLeave" },

                {
                    provider = icons.misc.record,
                    hl = { fg = colors.orange, bold = true },
                },
                surround({ "[", "]" }, nil, {
                    provider = function(self)
                        return vim.fn.reg_recording()
                    end,
                    hl = { fg = colors.green, bold = true },
                }),
            }

            local show_cmd = {
                condition = function()
                    return vim.opt.showcmdloc:get() == "statusline"
                end,
                provider = "%0.9(%S%)",
            }

            local lazy = {
                condition = require("lazy.status").has_updates,
                provider = function(self)
                    return require("lazy.status").updates()
                end,
                hl = { fg = "#ff9e64" },
                update = {
                    "User",
                    pattern = "LazyUpdate",
                },
                on_click = {
                    callback = function()
                        require("lazy").update()
                    end,
                    name = "heirline_update_plugins",
                },
            }

            local tabline_offset = {
                condition = function(self)
                    self.title = "Explorer"
                    self.win = vim.api.nvim_tabpage_list_wins(0)[1]
                    self.buf = vim.api.nvim_win_get_buf(self.win)
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = self.buf })
                    return filetype.is_panel_filetype(ft, filetype.left_panel_filetype_list)
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
                                    return self.is_active
                                end,
                                update = { "BufEnter", "DiagnosticChanged" },
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
                    insert_with_child_condition(
                        {
                            condition = function(self)
                                return self.is_active
                            end,
                        },
                        file_modified,
                        file_readonly
                    )
                ),
                padding_before({
                    provider = icons.misc.close,
                    hl = { fg = colors.gray },
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
                left_trunc = left_trunc or { provider = icons.surround.chevron_left }
                right_trunc = right_trunc or { provider = icons.surround.chevron_right }

                left_trunc.on_click = {
                    callback = function(self)
                        self._buflist[1]._cur_page = self._cur_page - 1
                        self._buflist[1]._force_page = true
                        vim.cmd.redrawtabline()
                    end,
                    name = "heirline_tabline_prev",
                }
                right_trunc.on_click = {
                    callback = function(self)
                        self._buflist[1]._cur_page = self._cur_page + 1
                        self._buflist[1]._force_page = true
                        vim.cmd.redrawtabline()
                    end,
                    name = "heirline_tabline_next",
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
                            self._buflist[#self._buflist + 1] = self
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
                { provider = icons.surround.chevron_left, hl = { fg = colors.gray } },
                { provider = icons.surround.chevron_right, hl = { fg = colors.gray } }
            )

            --- A helper function for decoding statuscolumn click events with mouse click pressed, modifier keys, as well as which signcolumn sign was clicked if any
            ---@param self any the self parameter from Heirline component on_click.callback function call
            ---@param minwid any the minwid parameter from Heirline component on_click.callback function call
            ---@param clicks any the clicks parameter from Heirline component on_click.callback function call
            ---@param button any the button parameter from Heirline component on_click.callback function call
            ---@param mods any the button parameter from Heirline component on_click.callback function call
            ---@return table # the argument table with the decoded mouse information and signcolumn signs information
            -- @usage local heirline_component = { on_click = { callback = function(...) local args = require("astroui.status").utils.statuscolumn_clickargs(...) end } }
            local function statuscolumn_clickargs(self, minwid, clicks, button, mods)
                local args = {
                    minwid = minwid,
                    clicks = clicks,
                    button = button,
                    mods = mods,
                    mousepos = vim.fn.getmousepos(),
                }
                args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
                if args.char == " " then
                    args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
                end

                if not self.signs then self.signs = {} end
                args.sign = self.signs[args.char]
                if not args.sign then -- update signs if not found on first click
                    if not self.bufnr then
                        self.bufnr = vim.api.nvim_get_current_buf()
                    end
                    local row = args.mousepos.line - 1
                    for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(self.bufnr, -1, { row, 0 }, { row, -1 }, { details = true, type = "sign" })) do
                        local sign = extmark[4]
                        if not (self.namespaces and self.namespaces[sign.ns_id]) then
                            self.namespaces = {}
                            for ns, ns_id in pairs(vim.api.nvim_get_namespaces()) do
                                self.namespaces[ns_id] = ns
                            end
                        end
                        if sign.sign_text then
                            self.signs[sign.sign_text:gsub("%s", "")] = {
                                name = sign.sign_name,
                                text = sign.sign_text,
                                texthl = sign.sign_hl_group or "NoTexthl",
                                namespace = sign.ns_id and self.namespaces[sign.ns_id],
                            }
                        end
                    end
                    args.sign = self.signs[args.char]
                end
                vim.api.nvim_set_current_win(args.mousepos.winid)
                vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
                return args
            end

            local ffi = require("ffi")
            -- Custom C extension to get direct fold information from Neovim
            ffi.cdef([[
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
            ]])

            local fillchars = vim.opt.fillchars:get()
            local foldopen = fillchars.foldopen or icons.fold.FoldOpened
            local foldclosed = fillchars.foldclose or icons.fold.FoldClosed
            local foldsep = fillchars.foldsep or icons.fold.FoldSeparator

            local fold = {
                condition = function(self)
                    return vim.opt.foldcolumn:get() ~= "0"
                end,
                provider = function(self)
                    -- move to M.fold_indicator
                    local wp = ffi.C.find_window_by_handle(0, ffi.new("Error")) -- get window handler
                    local width = ffi.C.compute_foldcolumn(wp, 0)               -- get foldcolumn width
                    -- get fold info of current line
                    local foldinfo = width > 0 and ffi.C.fold_info(wp, vim.v.lnum) or { start = 0, level = 0, llevel = 0, lines = 0 }

                    local str = ""
                    if width ~= 0 then
                        str = vim.v.relnum > 0 and "%#FoldColumn#" or "%#CursorLineFold#"
                        if foldinfo.level == 0 then
                            str = str .. string.rep(" ", width)
                        else
                            local closed = foldinfo.lines > 0
                            local first_level = foldinfo.level - width - (closed and 1 or 0) + 1
                            if first_level < 1 then
                                first_level = 1
                            end

                            for col = 1, width do
                                str = str
                                    .. (
                                        (vim.v.virtnum ~= 0 and foldsep)
                                        or ((closed and (col == foldinfo.level or col == width)) and foldclosed)
                                        or ((foldinfo.start == vim.v.lnum and first_level + col > foldinfo.llevel) and foldopen)
                                        or foldsep
                                    )
                                if col == foldinfo.level then
                                    str = str .. string.rep(" ", width - col)
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
                        if char == (fillchars.foldopen or icons.fold.FoldOpened) then
                            vim.cmd.normal({ "zc", bang = true })
                        elseif char == (fillchars.foldcolse or icons.fold.FoldClosed) then
                            vim.cmd.normal({ "zo", bang = true })
                        end
                    end,
                    name = "heirline_fold_click",
                },
            }

            -- local function to resolve the first sign in the signcolumn
            -- specifically for usage when `signcolumn=number`
            local function resolve_sign(bufnr, lnum)
                local row = lnum - 1
                local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, -1, { row, 0 }, { row, -1 }, { details = true, type = "sign" })
                local ret
                for _, extmark in pairs(extmarks) do
                    local sign_def = extmark[4]
                    if sign_def.sign_text and (not ret or (ret.priority < sign_def.priority)) then ret = sign_def end
                end
                if ret then return { text = ret.sign_text, texthl = ret.sign_hl_group } end
            end

            local number = {
                condition = function(self)
                    self.number, self.relativenumber = vim.opt.number:get(), vim.opt.relativenumber:get()
                    return self.number or self.relativenumber
                end,
                provider = function(self)
                    local lnum, relnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
                    local number, relativenumber = self.number, self.relativenumber
                    local bufnr = self and self.bufnr or 0
                    local sign = vim.opt.signcolumn:get():find("nu") and resolve_sign(bufnr, lnum)
                    local str
                    if virtnum ~= 0 then
                        str = "%="
                    elseif sign then
                        str = sign.text
                        if sign.texthl then
                            str = "%#" .. sign.texthl .. "#" .. str .. "%*"
                        end
                        str = "%=" .. str
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
                            if utils.is_available("nvim-dap") then
                                require("dap").toggle_breakpoint()
                            end
                        end
                    end,
                    name = "heirline_line_click",
                },
            }

            local sign_handlers = {}

            -- gitsigns handlers
            local gitsigns_handler = function(_)
                local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
                if gitsigns_avail then
                    vim.schedule(gitsigns.preview_hunk)
                end
            end
            for _, sign in ipairs { "Topdelete", "Untracked", "Add", "Change", "Changedelete", "Delete" } do
                local name = "GitSigns" .. sign
                if not sign_handlers[name] then
                    sign_handlers[name] = gitsigns_handler
                end
            end

            -- diagnostic handlers
            local diagnostics_handler = function(args)
                if args.mods:find("c") then
                    vim.schedule(vim.lsp.buf.code_action)
                else
                    vim.schedule(vim.diagnostic.open_float)
                end
            end
            for _, sign in ipairs { "Error", "Hint", "Info", "Warn" } do
                local name = "DiagnosticSign" .. sign
                if not sign_handlers[name] then
                    sign_handlers[name] = diagnostics_handler
                end
            end

            -- DAP handlers
            local dap_breakpoint_handler = function(_)
                local dap_avail, dap = pcall(require, "dap")
                if dap_avail then
                    vim.schedule(dap.toggle_breakpoint)
                end
            end
            for _, sign in ipairs { "", "Rejected", "Condition" } do
                local name = "DapBreakpoint" .. sign
                if not sign_handlers[name] then
                    sign_handlers[name] = dap_breakpoint_handler
                end
            end

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
                        if args.sign then
                            local handler = args.sign.name ~= "" and sign_handlers[args.sign.name]
                            if not handler then
                                handler = sign_handlers[args.sign.namespace]
                            end
                            if not handler then
                                handler = sign_handlers[args.sign.texthl]
                            end
                            if handler then
                                handler(args)
                            end
                        end
                    end,
                    name = "heirline_sign_click",
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
                        buftype = buftype.skip_buftype_list,
                        filetype = filetype.skip_filetype_list,
                    })
                end,

                padding_after(mode, 2),
                padding_after(file_size, 2),
                padding_after(search_count, 2),
                padding_after(show_cmd, 2),
                align,
                padding_before(lazy, 2),
                padding_before(ruler, 2),
                padding_before(scrollbar),
            }

            local default_statusline = {
                padding_after(mode, 2),
                padding_after(insert_with_child_condition(
                    { flexible = 2 },
                    insert_with_child_condition({}, git_branch, git_status),
                    git_status
                ), 2),
                padding_after(insert_with_child_condition(
                    { flexible = 1 },
                    insert_with_child_condition({}, lsp_info, padding_before(linter), diagnostic),
                    insert_with_child_condition({}, lsp_info, diagnostic),
                    diagnostic
                ), 2),
                padding_after(formatter, 2),
                padding_after(dap, 2),
                padding_after(file_size, 2),
                padding_after(search_count, 2),
                padding_after(macro, 2),
                padding_after(show_cmd, 2),
                align,
                padding_before(lazy, 2),
                padding_before(file_indent, 2),
                padding_before(file_encoding, 2),
                padding_before(file_format, 2),
                padding_before(ruler, 2),
                padding_before(scrollbar),
            }

            return {
                statusline = {
                    hl = { bg = colors.black },
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
                        local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                        return not vim.tbl_contains(lsp.lsp_filetype_list, ft)
                    end,
                },
            }
        end,
    },

    {
        "SmiteshP/nvim-navic",
        enabled = not environment.is_vscode,
        init = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client.supports_method("textDocument/documentSymbol") then
                        require("nvim-navic").attach(client, args.buf)
                    end
                end,
            })
        end,
        lazy = true,
        opts = {
            icons = icons.kinds,
            lazy_update_content = true,
        },
    },
}
