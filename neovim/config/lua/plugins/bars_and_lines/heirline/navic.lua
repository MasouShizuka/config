return {
    condition = function(self)
        return package.loaded["nvim-navic"]
    end,
    static = {
        -- create a type highlight map
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
        -- bit operation dark magic, see below...
        enc = function(line, col, winnr)
            return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
        end,
        -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
        dec = function(c)
            local line = bit.rshift(c, 16)
            local col = bit.band(bit.rshift(c, 6), 1023)
            local winnr = bit.band(c, 63)
            return line, col, winnr
        end,
    },
    init = function(self)
        local colors = require("utils.colors")

        local separator = " " .. require("utils.icons").fold.FoldClosed .. " "
        local children = { { provider = " " } }

        local filename = self.filename or vim.api.nvim_buf_get_name(0)
        filename = vim.fn.fnamemodify(filename, ":p:.")
        if require("utils.environment").is_windows then
            filename = filename:gsub("\\", "/")
        end
        for token in filename:gmatch("([^/]+)/?") do
            children[#children + 1] = {
                provider = token,
                hl = { fg = colors.colors.white },
            }
            children[#children + 1] = {
                provider = separator,
            }
        end
        table.remove(children, #children)
        table.insert(children, #children, require("plugins.bars_and_lines.heirline.file").file_icon)

        local navic = require("nvim-navic")
        local is_available = navic.is_available()
        if is_available then
            local data = navic.get_data() or {}
            for _, d in ipairs(data) do
                -- encode line and column numbers into a single integer
                local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
                local child = {
                    {
                        provider = separator,
                    },
                    {
                        provider = d.icon,
                        hl = self.type_hl[d.type],
                    },
                    {
                        -- escape `%`s (elixir) and buggy default separators
                        provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ""),
                        -- highlight icon only or location name as well
                        -- hl = self.type_hl[d.type],
                        hl = { fg = colors.colors.white },

                        on_click = {
                            -- pass the encoded position through minwid
                            minwid = pos,
                            callback = function(_, minwid)
                                vim.cmd.normal({ "m'", bang = true })

                                -- decode
                                local line, col, winnr = self.dec(minwid)
                                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                            end,
                            name = "heirline_navic",
                        },
                    },
                }
                children[#children + 1] = child
            end
        end
        -- instantiate the new child, overwriting the previous one
        self.child = self:new(children, 1)
    end,
    -- evaluate the children containing navic components
    provider = function(self)
        return self.child:eval()
    end,
    update = "CursorMoved",
}
