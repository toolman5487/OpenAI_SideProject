# OpenAI_SideProject
OpenAI_SideProject 是一個使用 Swift 開發的 iOS 應用，透過與 OpenAI API 串接，實現類似 ChatGPT 的多聊天室體驗。專案以 UIKit 為基礎，採用 MVVM 架構設計，並搭配第三方套件處理網路請求、UI 排版與動畫，整體專案架構清晰、擴充性高，適合作為學習與展示使用。

## 專案功能
本應用主打簡潔的多人聊天介面，核心功能包含與 GPT API 對話、多聊天室切換、自動命名、訊息狀態提示與本地訊息儲存。使用者可新增多個聊天室，每個聊天室會自動命名為首句發問，並記錄歷史訊息，重啟 App 時可保留內容。
聊天室畫面具備訊息自動捲動、狀態同步、動畫效果與深色模式支援，整體操作流暢自然。

## 使用技術
專案使用 Swift 撰寫，UI 架構以 UIKit 搭配 SnapKit 完成版面配置。資料與邏輯分離，遵循 MVVM 架構，便於後續維護與測試。
API 串接方面使用 Alamofire 並搭配 escaping closure 處理非同步資料。動畫效果使用 Lottie。
本地儲存部分，使用 `UserDefaults` 搭配 `Codable` 進行聊天室與訊息資料的序列化與反序列化，提供簡易的本地持久化功能。考量效能與簡潔性，目前暫不採用 CoreData。

## 架構設計
專案的核心架構為 MVVM：
- ViewController 負責 UI 顯示與事件觸發。
- ViewModel 管理聊天室狀態、處理使用者輸入與 API 回應。
- Model 定義資料結構（例如 ChatRoom、ChatMessage、ChatResponse）。
聊天室資料透過 `ChatRoomManager` 作統一管理，並採 Singleton 模式確保狀態一致性。

## 安裝與執行
1. 使用 Git 下載專案：
https://github.com/toolman5487/OpenAI_SideProject
2. 開啟 Xcode，打開 `.xcodeproj` 或 `.xcworkspace`
3. 使用 Swift Package Manager 安裝必要套件
4. 編輯 `APIConfiguration.swift` 並輸入你的 OpenAI API 金鑰
5. 執行專案即可開始使用

## 聯絡方式
作者：Willy
Email：willy548798@gmail.com
