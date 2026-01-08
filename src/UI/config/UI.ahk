; Simplified UI.ahk for MicMute
; Developer: Suvojeet Sengupta

global ui_obj, about_obj, current_profile, onExitCallback
    , UI_scale:= A_ScreenDPI/96

; IE feature control
UI_setIeFeatures(f_obj, enabled){
    static reg_dir:= "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\"
        , executable:= A_IsCompiled? A_ScriptName : util_splitPath(A_AhkPath).fileName
    for feature, value in f_obj
        if(enabled)
            RegWrite, REG_DWORD, % "HKCU\" reg_dir feature, % executable, % value
        else
            RegDelete, % "HKCU\" reg_dir feature, % executable
}

UI_create(exitCallback){
    global
    onExitCallback:= exitCallback
    
    features:= {"FEATURE_BROWSER_EMULATION": 11001
        , "FEATURE_GPU_RENDERING": 1}
    UI_setIeFeatures(features, true)
    
    ui_obj:= new NeutronWindow()
    ui_obj.load(resources_obj.htmlFile.UI)
    UI_loadCss(ui_obj)
    
    about_obj:= new NeutronWindow()
    about_obj.load(resources_obj.htmlFile.about)
    UI_loadCss(about_obj)
}

UI_loadCss(p_obj){
    for _i, css in resources_obj.cssFile
        p_obj.doc.parentWindow.neutron.AddCSS_FromFile(css.file)
}

UI_show(p_profile:="", animate:=1){
    global
    
    Try {
        ; Set version
        ui_obj.doc.getElementById("version").innerText:= A_Version
        
        ; Set icon
        ui_obj.doc.getElementById("MicMute_icon").src:= resources_obj.pngIcon
        
        ; Populate microphone list
        UI_onRefreshDeviceList()
        
        ; Set current microphone
        if(current_profile && current_profile.Microphone && current_profile.Microphone.Length() > 0)
            ui_obj.doc.getElementById("microphone").value:= current_profile.Microphone[1].Name
        
        ; Set options
        ui_obj.doc.getElementById("MuteOnStartup").checked:= config_obj.MuteOnStartup
        ui_obj.doc.getElementById("StartOnBoot").checked:= util_StartupTaskExists()
        ui_obj.doc.getElementById("PreferTheme").value:= config_obj.PreferTheme
        
        ; Update status bar
        UI_updateStatusBar()
        
        ; Apply theme
        UI_updateTheme()
    } Catch e {
        util_log("[UI] Error loading UI: " e.Message)
    }
    
    ; Show window
    ui_obj.show("w650 h550", animate)
}

UI_updateStatusBar(){
    Try {
        if(!mic_controllers || mic_controllers.Length() == 0)
            return
        
        statusBar:= ui_obj.doc.getElementById("status_bar")
        statusText:= ui_obj.doc.getElementById("status_text")
        
        if(mic_controllers[1].state){
            statusBar.className:= "status-bar muted"
            statusText.innerText:= "Microphone Muted"
        }else{
            statusBar.className:= "status-bar"
            statusText.innerText:= "Microphone Active"
        }
    }
}

UI_onRefreshDeviceList(){
    Try {
        select:= ui_obj.doc.getElementById("microphone")
        select.innerHTML:= "<option value='All' selected>All Microphones</option>"
    }
}

UI_onSetMicrophone(neutron, micName){
    if(!current_profile)
        return
    
    ; Clear existing microphones and set new one
    current_profile.Microphone:= Array()
    current_profile.Microphone.Push(new MicrophoneTemplate(micName, "", ""))
    
    util_log("[UI] Set microphone to: " micName)
}

UI_onGlobalOption(optionName, flip:=0){
    if(flip)
        config_obj[optionName]:= !config_obj[optionName]
    else
        config_obj[optionName]:= ui_obj.doc.getElementById(optionName).checked? 1 : 0
    
    config_obj.exportConfig()
    util_log("[UI] " optionName " set to: " config_obj[optionName])
}

UI_toggleStartOnBoot(){
    if(util_StartupTaskExists()){
        util_DeleteStartupTask()
        util_log("[UI] Removed startup task")
    }else{
        util_CreateStartupTask()
        util_log("[UI] Created startup task")
    }
    ui_obj.doc.getElementById("StartOnBoot").checked:= util_StartupTaskExists()
}

UI_updateThemeOption(){
    config_obj.PreferTheme:= ui_obj.doc.getElementById("PreferTheme").value
    config_obj.exportConfig()
    UI_updateTheme()
    util_log("[UI] Theme set to: " config_obj.PreferTheme)
}

UI_updateTheme(){
    ; Apply dark/light theme to UI based on preference
    sysTheme:= util_getSystemTheme()
    if(sysTheme.Apps)
        ui_obj.doc.body.classList.add("dark-theme")
    else
        ui_obj.doc.body.classList.remove("dark-theme")
}

UI_onSaveAndClose(){
    ; Save current profile
    if(current_profile){
        micName:= ui_obj.doc.getElementById("microphone").value
        current_profile.Microphone:= Array()
        current_profile.Microphone.Push(new MicrophoneTemplate(micName, "", ""))
    }
    
    ; Save config
    config_obj.MuteOnStartup:= ui_obj.doc.getElementById("MuteOnStartup").checked? 1 : 0
    config_obj.PreferTheme:= ui_obj.doc.getElementById("PreferTheme").value
    config_obj.exportConfig()
    
    util_log("[UI] Configuration saved")
    
    ; Close and reload
    ui_obj.hide()
    if(onExitCallback)
        onExitCallback.call()
}

UI_onChange(neutron:="", funcName:="", params*){
    if(fn:= Func(funcName))
        fn.call(params*)
}

; About window functions
UI_showAbout(p_neutron:="", checkForUpdates:=0){
    Try {
        about_obj.doc.getElementById("version").innerText:= "v" A_Version
        about_obj.doc.getElementById("MicMute_icon").src:= resources_obj.pngIcon
    }
    
    about_obj.show("w420 h400")
}

UI_exitAbout(){
    about_obj.hide()
}

UI_launchURL(url, external:=0){
    if(external || InStr(url, "http"))
        Run, % url
    else
        Run, % A_ScriptDir "\" url
}

UI_launchReleasePage(version:=""){
    if(version)
        UI_launchURL("https://github.com/suvojeet-sengupta/AHK_MicMute/releases/tag/" version, 1)
    else
        UI_launchURL("https://github.com/suvojeet-sengupta/AHK_MicMute/releases", 1)
}

UI_flipVal(elemId){
    elem:= ui_obj.doc.getElementById(elemId)
    elem.checked:= !elem.checked
}