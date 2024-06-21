local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "koKR")

if not L then return end

L["CHANNELS_LIST"] = {
    SAY     = "S,말,ㄴ,SAY",
    YELL    = "Y,외침,외치기,SHOUT,ㅛ,YELL,SH,SHOUT",
    PARTY   = "P,PARTY,ㅔ,파티,ㅍ",
    RAID    = "공,RAID,RA,공격대,공대,RSAY",
    INSTANCE_CHAT = "I,인스턴스,ㅑ",
    RAID_WARNING = "RW,경보",
}

L["SAY"]     = "일반"
L["YELL"]    = "외침"
L["PARTY"]   = "파티"
L["RAID"]    = "공대"
L["INSTANCE"] = "인스턴스"
L["RAID_WARNING"] = "경보"

L["Inspect Target"] = "대상 살펴보기 "
L["Inspect Mouseover"] = "마우스오버 살펴보기"

L["SLASH_CMD_UPNE2"] = "/ㅇㅇ"
L["SLASH_CMD_UPNE3"] = "/dd"
L["SLASH_CMD_CALC2"] = "/계산"
L["SLASH_CMD_CALC_SILENT2"] = "/계산2"

L["SLASH_OPT_INTERRUPT"] = {
    ["차단"] = true,
    ["INT"]  = true, ["INTERRUPT"] = true
}

L["Calculator"] = "계산기"
L["Calculation Error"] = "계산 오류"

L["Turn On"] = "(|cffffffff켜기|r) "
L["Turn Off"] = "(|cff999999끄기|r) "

L["Item Level"]         = "아이템 레벨"
L["ANNOUNCE_INTERRUPT"] = "차단 알림"
L["ANNOUNCE_CHANNEL"]   = "차단 알림 채널"
L["Interrupt"]          = "차단"
L["No Target"]          = "대상 없음"
L["TOOLTIP_AURA_SRC"]   = "버프/디버프 툴팁에 [시전자 이름] 표시"
L["TOOLTIP_AURA_ID"]    = "버프/디버프 툴팁에 [주문 ID] 표시"
L["TRADE_CLASS_COLOR"]  = "거래창에서 상대방 직업색상 보이기"
L["DELETE_CONFIRM"]     = "\"지금파괴\" 자동 입력"
L["RAIDICON_TOT"]       = "[대상의 대상]/[주시대상의 대상] 공격대 아이콘 표시"
L["FIX_COMBATTEXT"]     = "로그인 시 전투 메시지 켜기"
L["Combat Message Enabled"] = "전투 메시지가 꺼져 있어서 켰습니다."
L["FIX_COMBATTEXT_HELP"] = "기본 UI나 애드온 오류로 꺼진 상황에 대비합니다."
L["CALLME_ON"]          = "내 이름 불렸을 때 알람(콜미)"
L["CALLME_SOUND"]       = "콜미 소리"
L["Play"]               = "듣기"
L["TOOLTIP_UNIT_ILVL"]  = "대상 툴팁에 [평균템레벨] 표시(살펴보기 후 적용)"
L["INSPECT_ILVL"]       = "살펴보기 [평균템레벨] 표시"
L["VEHICLEUI_SCALE"]    = "탈것 UI 크기 조정"
L["VEHICLEUI_HIDEBG"]   = "탈것 UI 배경 제거"
L["DRUID_MANABAR"]      = "드루이드 마나바 향상"
L["DRUID_MANABAR_HELP"] = "숫자 항상 표시, 폰트 크기 조정, 플레이어 프레임과 크기 맞춤, 테두리 제거. 되돌리려면 리로드가 필요합니다."
L["LFG_LEAVE_INSTANCE"] = "인스턴스 종료 시 나가기 팝업 표시"
L["LFG_LEAVE_WAIT"]     = "팝업 지속 시간"
L["FPS_SHOW"]           = "FPS 표시"
L["FPS_OPTION"]         = "FPS 표시 위치조절"
L["FPS: Anchor Point"]  = "기준점"
L["FPS: Anchor Frame"]  = "기준 프레임"
L["FPS: Anchor Frame's Anchor Point"] = "기준 프레임의 기준점"
L["FPS: X Offset"]      = "좌우 이동"
L["FPS: Y Offset"]      = "상하 이동"
L["Need reload to apply"] = "적용을 위해 리로드가 필요합니다."

-- koKR only
L["INSTANCE_CHAT_KR"] = "/ㅑ 를 인스턴스 채팅으로 사용"

L["TOPLEFT"]    = "좌상"
L["TOP"]        = "상"
L["TOPRIGHT"]   = "우상"
L["LEFT"]       = "좌"
L["CENTER"]     = "중간"
L["RIGHT"]      = "우"
L["BOTTOMLEFT"] = "좌하"
L["BOTTOM"]     = "하"
L["BOTTOMRIGHT"] = "우하"
