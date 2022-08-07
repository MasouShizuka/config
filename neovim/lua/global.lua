local global = {}

function global:load_variables()
    local os_name = vim.loop.os_uname().sysname
    self.is_windows = os_name == "Windows_NT"
    self.is_mac = os_name == "Darwin"
    self.is_linux = os_name == "Linux"

    self.is_vscode = vim.g.vscode

    self.home = self.is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")
    self.config_path = vim.fn.stdpath("config")
    self.data_path = vim.fn.stdpath("data")
end

global:load_variables()

return global
