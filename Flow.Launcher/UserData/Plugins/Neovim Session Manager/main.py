# -*- coding: utf-8 -*-

from os import listdir, remove, startfile
from os.path import isfile, join
from subprocess import PIPE, Popen

from flowlauncher import FlowLauncher, FlowLauncherAPI


class NeovimSessionManager(FlowLauncher):
    def __init__(self):
        self.platforms = {
            "Windows": {
                "session_dir": "C:/Users/MasouShizuka/AppData/Local/nvim-data/lazy/neovim-session-manager/sessions",
                # "cmd": "wezterm start --cwd \"{}\" -- nvim +",
                "cmd": "neovide --frame none",
                "icon": "💻",
            },
            "WSL": {
                "session_dir": "C:/Users/MasouShizuka/AppData/Local/nvim-data/lazy/neovim-session-manager/sessions_wsl",
                # "cmd": "wezterm start -- wsl --cd \"{}\" -e nvim +",
                "cmd": "neovide --frame none --wsl",
                "icon": "🐧",
            },
        }

        self.path_replacer = "__"
        self.colon_replacer = "++"

        super().__init__()

    def query(self, query):
        results = []
        for platform, info in self.platforms.items():
            for session in listdir(info["session_dir"]):
                if not isfile(join(info["session_dir"], session)):
                    continue

                working_dir = session.replace(self.path_replacer, "/")
                working_dir = working_dir.replace(self.colon_replacer, ":")
                if working_dir.endswith(".json"):
                    working_dir = working_dir[:-5]
                elif working_dir.endswith(".vim"):
                    working_dir = working_dir[:-4]

                title = info["icon"] + ": " + working_dir.split("/")[-1]
                sub_title = "Session" + ": " + working_dir

                flag = True
                query_lower = query.lower()
                session_lower = platform.lower() + working_dir.lower()
                for s in query_lower.split():
                    if s not in session_lower:
                        flag = False
                        break
                if not flag:
                    continue

                results.append(
                    {
                        "Title": title,
                        "SubTitle": sub_title,
                        "IcoPath": "neovim.png",
                        "JsonRPCAction": {
                            "method": "open_session",
                            "parameters": [info["cmd"], working_dir],
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
                "IcoPath": "neovim.png",
                "JsonRPCAction": {
                    "method": "open_directory",
                    "parameters": [working_dir],
                },
            },
            {
                "Title": "Delete Session",
                "SubTitle": working_dir,
                "IcoPath": "neovim.png",
                "JsonRPCAction": {
                    "method": "delete_session",
                    "parameters": [session, working_dir],
                },
            },
        ]

    def open_session(self, cmd, working_dir):
        try:
            if working_dir.startswith("/mnt/"):
                working_dir = f"{working_dir[5]}:{working_dir[6:]}"

            Popen(
                str.format(cmd, working_dir),
                stdout=PIPE,
                stderr=PIPE,
                cwd=working_dir,
            )
        except:
            pass
        finally:
            FlowLauncherAPI.hide_app()

    def open_directory(self, working_dir):
        try:
            startfile(working_dir)
        except:
            pass
        finally:
            FlowLauncherAPI.hide_app()

    def delete_session(self, session, working_dir):
        try:
            remove(join(working_dir, session))
        except:
            pass


if __name__ == "__main__":
    NeovimSessionManager()
