const AddonName = "FolderSettings";
const Addon_Id = AddonName.toLowerCase();
RunEventUI("BrowserCreatedEx");

Addons.FolderSettings = {
	GetCurrentSetting: async function (bForce) {
		const nFormat = GetNum(document.E.Format.value);
		const FV = await te.Ctrl(CTRL_FV);
		const r = await Promise.all([api.GetDisplayNameOf(FV, (nFormat ? 0 : SHGDN_FORADDRESSBAR) | SHGDN_FORPARSING | SHGDN_FORPARSINGEX), FV.CurrentViewMode, FV.IconSize, FV.GetColumns(nFormat), FV.GroupBy, FV.SortColumns, FV.SortColumn, FV.GetSortColumn(nFormat)]);
		const path = r[0];
		let s = ["FV.SetViewMode(", r[1], ",", r[2], ");\n"];
		s.push("FV.Columns='", r[3], "';\n");
		s.push("FV.GroupBy='", r[4], "';\n");
		if ((r[5] || "").split(/;/).length > 2 && !document.E.XP.checked && r[6] != "System.Null") {
			s.push("FV.SortColumns='", r[5], "';\n");
		} else {
			s.push("FV.SortColumn='", r[7], "';\n");
		}
		s = s.join("");
		if (bForce || await confirmOk([path, s].join("\n"))) {
			document.E.Filter.value = path;
			document.E.Path.value = s;
			SetType(document.E.Type, "JScript");
		}
		ChangeX("List");
	},

	Load: async function () {
		if (!g_x.List) {
			let arFunc = await api.CreateObject("Array");
			await MainWindow.RunEvent1("AddType", arFunc);
			const oa = document.E.Type;
			if (window.chrome) {
				arFunc = await api.CreateObject("SafeArray", arFunc);
			}
			for (let i = 0; i < arFunc.length; ++i) {
				const o = oa[++oa.length - 1];
				const s = arFunc[i];
				o.value = s;
				o.innerText = await GetText(s);
			}
			g_x.List = document.E.List;
			g_x.List.length = 0;
			const xml = await OpenXmlUI(AddonName + ".xml", false, false);
			if (xml) {
				document.E.Format.selectedIndex = GetNum(xml.documentElement.getAttribute("Format"));
				document.E.XP.checked = GetNum(xml.documentElement.getAttribute("XP"));
				const items = xml.getElementsByTagName("Item");
				let i = items.length;
				g_x.List.length = i;
				while (--i >= 0) {
					const item = items[i];
					SetData(g_x.List[i], [item.getAttribute("Filter"), item.text || item.textContent, item.getAttribute("Type")]);
				}
			}
			EnableSelectTag(g_x.List);
		}
	},

	Save: async function () {
		if (g_Chg.List) {
			const xml = CreateXmlUI(true);
			xml.documentElement.setAttribute("Format", document.E.Format.selectedIndex);
			xml.documentElement.setAttribute("XP", GetNum(document.E.XP.checked));
			const o = document.E.List;
			for (let i = 0; i < o.length; i++) {
				const item = xml.createElement("Item");
				const a = o[i].value.split(g_sep);
				item.setAttribute("Filter", a[0]);
				SetXmlText(item, a[1]);
				item.setAttribute("Type", a[2]);
				xml.documentElement.appendChild(item);
			}
			await SaveXmlExUI(Addon_Id + ".xml", xml);
			if (await MainWindow.Sync.FolderSettings) {
				MainWindow.Sync.FolderSettings.xml = null;
			}
		}
	},

	Edit: function() {
		if (g_x.List.selectedIndex < 0) {
			return;
		}
		const a = g_x.List[g_x.List.selectedIndex].value.split(g_sep);
		document.E.Filter.value = a[0];
		document.E.Path.value = a[1];
		SetType(document.E.Type, a[2]);
	},

	Replace: function () {
		ClearX();
		if (g_x.List.selectedIndex < 0) {
			g_x.List.selectedIndex = ++g_x.List.length - 1;
			EnableSelectTag(g_x.List);
		}
		const sel = g_x.List[g_x.List.selectedIndex];
		o = document.E.Type;
		SetData(sel, [document.E.Filter.value, document.E.Path.value, o[o.selectedIndex].value]);
		g_Chg.List = true;
	},

	Init: async function () {
		await ApplyLang(document);
		await Addons.FolderSettings.Load();

		if (!await WebBrowser.OnClose) {
			document.title = await GetAddonInfo(Addon_Id).Name;
			WebBrowser.OnClose = async function (WB) {
				await SetOptions(TEOk, null, ContinueOptions);
				if (g_nResult != 4) {
					WB.Close();
				}
				g_nResult = 0;
			};
			document.getElementById("_ok").style.display = "block";
			document.getElementById("_cancel").style.display = "block";
		}
		document.body.style.visibility = "";
		if (await dialogArguments.GetCurrent) {
			let bNew = true;
			const FV = te.Ctrl(CTRL_FV);
			let path = await api.GetDisplayNameOf(FV, SHGDN_FORADDRESSBAR | SHGDN_FORPARSING);
			const path2 = await api.GetDisplayNameOf(FV, SHGDN_FORPARSING);
			for (let i = g_x.List.length; i-- > 0;) {
				const a = g_x.List[i].value.split(g_sep);
				if (SameText(a[0], path) || SameText(a[0], path2)) {
					g_x.List.selectedIndex = i;
					await Addons.FolderSettings.Edit();
					bNew = false;
					break;
				}
			}
			if (bNew) {
				Addons.FolderSettings.GetCurrentSetting(true);
			}
		}
	},

	Change: function () {
		g_Chg.List = true;
	}
}
TEOk = async function () {
	if (g_Chg.Data) {
		await Addons.FolderSettings.Replace();
	}
	await Addons.FolderSettings.Save();
}

