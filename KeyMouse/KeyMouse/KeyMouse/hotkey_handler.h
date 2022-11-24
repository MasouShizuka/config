#pragma once
#include"stdafx.h"

#define DISABLED 0
// hotkeys' ID.
#define  HOTKEY_A   1
#define  HOTKEY_B   2
#define  HOTKEY_C   3
#define  HOTKEY_D   4
#define  HOTKEY_E   5
#define  HOTKEY_F   6
#define  HOTKEY_G   7
#define  HOTKEY_H   8
#define  HOTKEY_I   9
#define  HOTKEY_J   10
#define  HOTKEY_K   11
#define  HOTKEY_L   12
#define  HOTKEY_M   13
#define  HOTKEY_N   14
#define  HOTKEY_O   15
#define  HOTKEY_P   16
#define  HOTKEY_Q   17
#define  HOTKEY_R   18
#define  HOTKEY_S   19
#define  HOTKEY_T   20
#define  HOTKEY_U   21
#define  HOTKEY_V   22
#define  HOTKEY_W   23
#define  HOTKEY_X   24
#define  HOTKEY_Y   25
#define  HOTKEY_Z   26

#define  TOGGLEENABLE        27
#define  FORCENOTUSECACHE    28
#define  CLEANTAG            29
#define  RIGHTCLICKPREFIX    30
#define  SINGLECLICKPREFIX   31
#define  DOUBLECLICKPREFIX   32
#define  SELECTMODESINGLE    33
#define  SELECTMODEDOUBLE    34
#define  FASTSELECTMODE      35
#define  HINTMODESINGLE      36
#define  HINTMODEDOUBLE      37
#define  FASTHINTMODE        38

namespace KeyMouse {
BOOL RegCustomHotKey(HWND hWnd, std::string key);
BOOL UnregCustomHotKey(HWND hWnd, std::string key);
BOOL RegisterAllHotKey(HWND hWnd, bool exclude_toggle = false);
BOOL RegisterTagHotKey(HWND hWnd);
BOOL UnregisterAllHotKey(HWND hWnd, bool exclude_toggle = false);
BOOL UnregisterTagHotKey(HWND hWnd);
}
