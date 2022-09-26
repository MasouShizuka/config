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

    ChangeLayout = "ChangeLayout"
    ToggleMaximize = "ToggleMaximize"
    ToggleMonocle = "ToggleMonocle"
    TogglePause = "TogglePause"
    ToggleTiling = "ToggleTiling"

    CycleFocusMonitor = "CycleFocusMonitor"
    CycleFocusWorkspace = "CycleFocusWorkspace"
    CycleFocusWindow = "CycleFocusWindow"
    FocusChange = "FocusChange"
    FocusMonitorNumber = "FocusMonitorNumber"
    FocusWorkspaceNumber = "FocusWorkspaceNumber"
    FocusMonitorWorkspaceNumber = "FocusMonitorWorkspaceNumber"
    PromoteFocus = "PromoteFocus"

    CycleMoveWindow = "CycleMoveWindow"
    Promote = "Promote"

    EnsureWorkspaces = "EnsureWorkspaces"
    NewWorkspace = "NewWorkspace"
    WorkspaceName = "WorkspaceName"

    Manage = "Manage"
    Unmanage = "Unmanage"

    MoveContainerToMonitorNumber = "MoveContainerToMonitorNumber"
    MoveContainerToWorkspaceNumber = "MoveContainerToWorkspaceNumber"
    MoveWorkspaceToMonitorNumber = "MoveWorkspaceToMonitorNumber"
    SendContainerToMonitorNumber = "SendContainerToMonitorNumber"
    SendContainerToWorkspaceNumber = "SendContainerToWorkspaceNumber"

    ReloadConfiguration = "ReloadConfiguration"
    WatchConfiguration = "WatchConfiguration"
