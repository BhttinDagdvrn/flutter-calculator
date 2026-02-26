# Flutter Calculator (Windows Calculator UI Clone)

Windows Calculator (Standard) arayüzünü baz alan, Flutter ile geliştirilmiş masaüstü uyumlu hesap makinesi arayüzü.

## Mevcut Özellikler

### Arayüz (UI)
- Windows Calculator “Standard” tasarımına benzer koyu tema
- Üst AppBar:
  - Menü ikonu (sol)
  - Başlık: **Standard**
  - History ikonu (sağ)
- Tuş takımı (keypad) grid düzeni:
  - `%`, `CE`, `C`, `⌫`
  - `1/x`, `x²`, `²√x`, `÷`
  - `7 8 9 ×`
  - `4 5 6 −`
  - `1 2 3 +`
  - `+/- 0 , =`
- `=` tuşu accent (mavi) renkte
- Buton hover davranışı
- Mouse cursor sabit (desktop hissi)

### Display (Ekran)
- **Çift satırlı display**
  - Üst satır: expression/history preview (ör. `1 + 2 =`)
  - Alt satır: ana sonuç / giriş sayısı
- Alt satır tek satıra kilitli (wrap yok, butonların arkasına kayma engelli)

### State / Mantık (Provider yok)
- Provider kullanılmadan, `setState` tabanlı state yönetimi
- Tek merkezden input yönetimi (button label -> handler mantığı)
- Temel dört işlem altyapısı:
  - `+`, `−`, `×`, `÷`
  - `=` ile hesaplama
- Operatör mantığı:
  - İlk sayı `_acc` içinde tutulur
  - Seçilen operatör `_op` içinde tutulur
  - Operatör sonrası yeni sayı girişine geçiş (`_resetOnNextDigit`)

### Backspace (⌫)
- Son karakter silme
- Tek hane kalınca `0`’a dönme
- Operatörden sonra (yeni sayı beklerken) `0`’a dönme

### Limit / Hata Kontrolleri
- Maksimum **12 basamak** giriş limiti (13. basamak yazılmaz)
- Sonuç **12 basamağı aşarsa** `Overflow` gösterimi
- `NaN` / `Infinity` gibi durumlarda `Error` gösterimi

### Görsel Biçimlendirme
- Sayı gösteriminde **her 3 basamakta bir nokta** ile binlik ayırıcı (örn. `1234567` -> `1.234.567`)
  - Not: Bu sadece UI formatlamasıdır, state değeri ham sayı olarak tutulur.

## Notlar / Planlananlar
- `,` (ondalık) girişi ve doğru formatlama (`12.345,67`)
- `%`, `+/-`, `CE`, `1/x`, `x²`, `²√x` fonksiyonlarının gerçek matematiksel davranışları
- Gerçek “History panel” (sağdan açılan geçmiş listesi) ve işlem kayıtları
- Daha gelişmiş hesap makinesi davranışları (Windows Calculator ile birebir)