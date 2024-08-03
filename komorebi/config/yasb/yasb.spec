# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['src\\main.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=['core.widgets.komorebi.workspaces', 'core.widgets.komorebi.active_layout', 'core.widgets.komorebi.multi_window', 'core.widgets.yasb.input_method', 'core.widgets.yasb.wifi', 'core.widgets.yasb.traffic', 'core.widgets.yasb.cpu', 'core.widgets.yasb.memory', 'core.widgets.yasb.gpu', 'core.widgets.yasb.battery', 'core.widgets.yasb.clock'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='yasb',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['img\\yasb_icon.ico'],
)
