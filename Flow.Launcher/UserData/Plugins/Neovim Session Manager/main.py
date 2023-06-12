# -*- coding: utf-8 -*-

import os
from subprocess import Popen, PIPE

from flowlauncher import FlowLauncher
from flowlauncher import FlowLauncherAPI


class NeovimSessionManager(FlowLauncher):
    def __init__(self):
        self.session_dir = "C:/Users/MasouShizuka/AppData/Local/nvim-data/lazy/neovim-session-manager/sessions"
        self.path_replacer = "__"
        self.colon_replacer = "++"

        self.cmd = "wezterm start --cwd"
        self.args = "-- nvim +"

        self.session_list = os.listdir(self.session_dir)

        super().__init__()

    def query(self, query):
        results = []
        for session in self.session_list:
            working_dir = session.replace(self.path_replacer, "/")
            working_dir = working_dir.replace(self.colon_replacer, ":")
            name = working_dir.split("/")[-1]
            if query.lower() in working_dir.lower():
                results.append(
                    {
                        "Title": name,
                        "SubTitle": "Session: " + working_dir,
                        "IcoPath": "Images/neovim.png",
                        "JsonRPCAction": {
                            "method": "open_session",
                            "parameters": [working_dir],
                        },
                        "ContextData": [session, working_dir],
                    }
                )

        return results

    def context_menu(self, data):
        session, working_dir = data
        return [
            {
                "Title": "Open Directory",
                "SubTitle": working_dir,
                "IcoPath": "Images/neovim.png",
                "JsonRPCAction": {
                    "method": "open_directory",
                    "parameters": [working_dir],
                },
            },
            {
                "Title": "Delete Session",
                "SubTitle": working_dir,
                "IcoPath": "Images/neovim.png",
                "JsonRPCAction": {
                    "method": "delete_session",
                    "parameters": [session],
                },
            },
        ]

    def open_session(self, working_dir):
        try:
            Popen(
                self.cmd + ' "' + working_dir + '" ' + self.args,
                stdout=PIPE,
                stderr=PIPE,
            )
        except:
            pass
        FlowLauncherAPI.hide_app()

    def open_directory(self, working_dir):
        try:
            os.startfile(working_dir)
        except:
            pass
        FlowLauncherAPI.hide_app()

    def delete_session(self, session):
        try:
            os.remove(os.path.join(self.session_dir, session))
        except:
            pass


if __name__ == "__main__":
    NeovimSessionManager()
