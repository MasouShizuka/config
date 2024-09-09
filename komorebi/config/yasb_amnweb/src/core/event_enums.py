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
    KomorebiUpdate = "KomorebiUpdate"
    KomorebiDisconnect = "KomorebiDisconnect"
    FocusWorkspaceNumber = "FocusWorkspaceNumber"
    FocusMonitorWorkspaceNumber = "FocusMonitorWorkspaceNumber"
    FocusChange = "FocusChange"
    ChangeLayout = "ChangeLayout"
    ToggleTiling = "ToggleTiling"
    ToggleMonocle = "ToggleMonocle"
    ToggleMaximise = "ToggleMaximise"
    TogglePause = "TogglePause"
    EnsureWorkspaces = "EnsureWorkspaces"
    CycleFocusMonitor = "CycleFocusMonitor"
    CycleFocusWorkspace = "CycleFocusWorkspace"
    FocusMonitorNumber = "FocusMonitorNumber"
    ReloadConfiguration = "ReloadConfiguration"
    WatchConfiguration = "WatchConfiguration"
    Manage = "Manage"
    Unmanage = "Unmanage"
    MoveContainerToMonitorNumber = "MoveContainerToMonitorNumber"
    MoveContainerToWorkspaceNumber = "MoveContainerToWorkspaceNumber"
    MoveWorkspaceToMonitorNumber = "MoveWorkspaceToMonitorNumber"
    NewWorkspace = "NewWorkspace"
    SendContainerToMonitorNumber = "SendContainerToMonitorNumber"
    SendContainerToWorkspaceNumber = "SendContainerToWorkspaceNumber"
    WorkspaceName = "WorkspaceName"

    Cloak = "Cloak"
    Uncloak = "Uncloak"

    Close = "Close"
    # NOTE: komorebi 中 Minimize 包含 2 种 event：SocketMessage::Minimize 和 WindowManagerEvent::Minimize
    # 前者不带参数，后者带参数，一般应该捕获后者
    Minimize = "Minimize"

    CycleFocusWindow = "CycleFocusWindow"
    PromoteFocus = "PromoteFocus"

    CycleMoveWindow = "CycleMoveWindow"
    Promote = "Promote"

    SendContainerToMonitorWorkspaceNumber = "SendContainerToMonitorWorkspaceNumber"

    Show = "Show"
