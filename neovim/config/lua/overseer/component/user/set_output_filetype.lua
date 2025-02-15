return {
    desc = "Set the filetype of output",
    params = {
        filetype = {
            desc = "Filetype of the output window",
            type = "string",
            default = "",
        },
    },
    constructor = function(params)
        return {
            on_start = function(self, task)
                vim.api.nvim_set_option_value("filetype", params.filetype, { buf = task:get_bufnr() })
            end,
        }
    end,
}
