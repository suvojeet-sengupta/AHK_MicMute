; VoiceMeter.ahk - Floating voice level indicator
; Developer: Suvojeet Sengupta

global voicemeter_obj, voicemeter_timer, voicemeter_visible := false

voicemeter_create(){
    global
    
    voicemeter_obj := new NeutronWindow()
    
    ; Use inline HTML for reliability
    html := "
    (
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">
    <meta charset=""UTF-8"">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff;
            overflow: hidden;
        }
        .container { padding: 12px 16px; min-width: 220px; }
        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.85rem;
            font-weight: 600;
            color: #a0aec0;
        }
        .title svg { width: 16px; height: 16px; fill: #4facfe; }
        .close-btn {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            border: none;
            color: #a0aec0;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
        }
        .close-btn:hover { background: #e53e3e; color: white; }
        .meter-container {
            background: rgba(0, 0, 0, 0.3);
            border-radius: 8px;
            padding: 3px;
            margin-bottom: 8px;
        }
        .meter-bar {
            height: 24px;
            border-radius: 6px;
            background: linear-gradient(90deg, #48bb78 0%, #4facfe 50%, #f56565 100%);
            width: 0%;
            transition: width 0.08s ease-out;
            box-shadow: 0 0 10px rgba(79, 172, 254, 0.3);
        }
        .status {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.75rem;
        }
        .status-label { color: #718096; }
        .status-value { font-weight: 600; color: #4facfe; font-size: 0.9rem; }
        .status-muted { color: #f56565 !important; }
        .status-quiet { color: #48bb78 !important; }
    </style>
</head>
<body>
    <div class=""container"">
        <div class=""header"">
            <div class=""title"">
                <svg viewBox=""0 0 24 24""><path d=""M12,2A3,3 0 0,1 15,5V11A3,3 0 0,1 12,14A3,3 0 0,1 9,11V5A3,3 0 0,1 12,2M19,11C19,14.53 16.39,17.44 13,17.93V21H11V17.93C7.61,17.44 5,14.53 5,11H7A5,5 0 0,0 12,16A5,5 0 0,0 17,11H19Z""/></svg>
                Voice Meter
            </div>
            <button class=""close-btn"" onclick=""ahk.voicemeter_hide()"">X</button>
        </div>
        <div class=""meter-container"">
            <div class=""meter-bar"" id=""meter_bar""></div>
        </div>
        <div class=""status"">
            <span class=""status-label"" id=""status_label"">Listening...</span>
            <span class=""status-value"" id=""level_text"">0%</span>
        </div>
    </div>
</body>
</html>
    )"
    
    voicemeter_obj.load("about:blank")
    voicemeter_obj.doc.write(html)
    voicemeter_obj.doc.close()
}

voicemeter_show(){
    global
    
    if(!voicemeter_obj)
        voicemeter_create()
    
    ; Position at bottom-right of screen
    SysGet, MonitorWorkArea, MonitorWorkArea
    posX := MonitorWorkAreaRight - 270
    posY := MonitorWorkAreaBottom - 130
    
    voicemeter_obj.show("w260 h100 x" posX " y" posY)
    voicemeter_visible := true
    
    ; Start update timer (faster for smooth animation)
    voicemeter_timer := Func("voicemeter_update")
    SetTimer, % voicemeter_timer, 30
    
    util_log("[VoiceMeter] Shown")
}

voicemeter_hide(){
    global
    
    Try {
        if(voicemeter_obj){
            voicemeter_obj.hide()
            voicemeter_visible := false
            
            ; Stop update timer
            if(voicemeter_timer)
                SetTimer, % voicemeter_timer, Off
        }
    }
    
    util_log("[VoiceMeter] Hidden")
}

voicemeter_toggle(){
    global
    
    if(voicemeter_visible)
        voicemeter_hide()
    else
        voicemeter_show()
}

voicemeter_update(){
    global
    
    if(!voicemeter_visible || !voicemeter_obj)
        return
    
    Try {
        ; Get mic peak level (0-100) - REAL audio activity
        level := 0
        isMuted := false
        
        if(mic_controllers && mic_controllers.Length() > 0){
            mic := mic_controllers[1]
            isMuted := mic.state
            
            ; Get PEAK meter value (actual voice activity)
            if(!isMuted){
                Try {
                    ; Get the audio meter interface for the mic device
                    peakValue := VA_GetDevicePeakValue(mic.device)
                    if(peakValue != "")
                        level := Round(peakValue * 100)
                }
            }
        }
        
        ; Clamp values
        if(level < 0)
            level := 0
        if(level > 100)
            level := 100
        
        ; Update UI
        meterBar := voicemeter_obj.doc.getElementById("meter_bar")
        levelText := voicemeter_obj.doc.getElementById("level_text")
        statusLabel := voicemeter_obj.doc.getElementById("status_label")
        
        if(!meterBar || !levelText)
            return
        
        if(isMuted){
            meterBar.style.width := "0%"
            levelText.innerText := "MUTED"
            levelText.className := "status-value status-muted"
            statusLabel.innerText := "Mic is muted"
        }else{
            meterBar.style.width := level "%"
            levelText.innerText := level "%"
            
            if(level > 5){
                levelText.className := "status-value"
                statusLabel.innerText := "Speaking..."
            }else{
                levelText.className := "status-value status-quiet"
                statusLabel.innerText := "Listening..."
            }
        }
    }
}

; Helper function to get device peak value
VA_GetDevicePeakValue(device){
    Try {
        ; Get audio meter for the device
        if pMeter := VA_GetAudioMeter(device) {
            VarSetCapacity(fPeak, 4, 0)
            ; GetPeakValue is at offset 12 in IAudioMeterInformation
            DllCall(NumGet(NumGet(pMeter+0)+12), "ptr", pMeter, "ptr", &fPeak)
            peak := NumGet(fPeak, 0, "float")
            ObjRelease(pMeter)
            return peak
        }
    }
    return 0
}
