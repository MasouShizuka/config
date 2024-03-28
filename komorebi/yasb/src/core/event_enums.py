from enum import Enum, EnumMeta


class MetaEvent(EnumMeta):
    def __contains__(cls, item):
        try:
            cls(item)
        except ValueError:
            return False
        return True


class Event(Enum, metaclass=MetaEvent):
    pass


class KomorebiEvent(Event):
    KomorebiConnect = "KomorebiConnect"
    KomorebiDisconnect = "KomorebiDisconnect"
    KomorebiUpdate = "KomorebiUpdate"

    # SocketMessage

    ChangeLayout = "ChangeLayout"
    ToggleMaximize = "ToggleMaximize"
    ToggleMonocle = "ToggleMonocle"
    TogglePause = "TogglePause"
    ToggleTiling = "ToggleTiling"

    Cloak = "Cloak"
    Uncloak = "Uncloak"

    Close = "Close"
    # NOTE: komorebi 中 Minimize 包含 2 种 event：SocketMessage::Minimize 和 WindowManagerEvent::Minimize
    # 前者不带参数，后者带参数，一般应该捕获后者
    Minimize = "Minimize"

    CycleFocusMonitor = "CycleFocusMonitor"
    CycleFocusWindow = "CycleFocusWindow"
    CycleFocusWorkspace = "CycleFocusWorkspace"
    FocusMonitorNumber = "FocusMonitorNumber"
    FocusMonitorWorkspaceNumber = "FocusMonitorWorkspaceNumber"
    FocusWorkspaceNumber = "FocusWorkspaceNumber"
    PromoteFocus = "PromoteFocus"

    CycleMoveWindow = "CycleMoveWindow"
    Promote = "Promote"

    EnsureWorkspaces = "EnsureWorkspaces"
    NewWorkspace = "NewWorkspace"
    WorkspaceName = "WorkspaceName"

    MoveContainerToMonitorNumber = "MoveContainerToMonitorNumber"
    MoveContainerToWorkspaceNumber = "MoveContainerToWorkspaceNumber"
    MoveWorkspaceToMonitorNumber = "MoveWorkspaceToMonitorNumber"
    SendContainerToMonitorNumber = "SendContainerToMonitorNumber"
    SendContainerToMonitorWorkspaceNumber = "SendContainerToMonitorWorkspaceNumber"
    SendContainerToWorkspaceNumber = "SendContainerToWorkspaceNumber"

    ReloadConfiguration = "ReloadConfiguration"
    WatchConfiguration = "WatchConfiguration"

    # WindowManagerEvent

    FocusChange = "FocusChange"
    Manage = "Manage"
    Unmanage = "Unmanage"
    Show = "Show"

