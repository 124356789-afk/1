# Сборка iOS с Windows — как это реально работает

Другие правы **частично**: на Windows **нельзя** запустить Xcode, но **можно** собрать IPA, не имея Mac под рукой — через **облачный Mac** или **PWA**.

---

## Что правда, а что нет

| Утверждение | Правда? |
|-------------|---------|
| «Xcode ставят на Windows» | **Нет** — только macOS |
| «С Windows собирают через GitHub / Codemagic» | **Да** — Mac в облаке |
| «Flutter/Expo собирают iOS с Windows» | **Да** — сборка идёт на их серверах |
| «PWA — как приложение без сборки» | **Да** — Safari → на экран «Домой» |
| «Sideloadly ставит IPA с Windows» | **Да**, но **IPA** всё равно кто-то должен собрать |

---

## Способ A — PWA (0 сборки, только Windows + iPhone)

**~30 секунд**, Mac не нужен.

1. iPhone → **Safari** → `http://212.220.113.9:10124`
2. **Поделиться** → **На экран «Домой»**

Готово.

---

## Способ B — Codemagic (с Windows, бесплатный тариф)

Облачный Mac собирает IPA. Управление **из браузера на Windows**.

### Шаги

1. Зарегистрируйтесь на [codemagic.io](https://codemagic.io) (есть бесплатные минуты)
2. **Add application** → подключите GitHub/GitLab или загрузите zip папки `sfera_ios`
3. В Codemagic: **Team settings → Integrations → Developer Portal** — войдите **Apple ID** (бесплатный аккаунт подходит для development)
4. В приложении выберите workflow **Sfera iOS** (файл `codemagic.yaml` уже в проекте)
5. Измените `bundle_identifier` на уникальный, если `com.sfera.messenger` занят
6. **Start new build** → дождитесь окончания → скачайте **.ipa**

### Установка IPA на iPhone с Windows

1. Скачайте [Sideloadly](https://sideloadly.io) (Windows)
2. Подключите iPhone по USB
3. Перетащите `.ipa` в Sideloadly, введите Apple ID
4. На iPhone: **Настройки → Основные → VPN и управление устройством** → Доверять

> Бесплатный Apple ID: приложение работает **7 дней**, потом переустановить через Sideloadly.

---

## Способ C — GitHub Actions (с Windows через git push)

В проекте есть `.github/workflows/ios-build.yml`.

### Минимум (только проверка сборки)

1. Создайте репозиторий на GitHub, залейте папку `sfera_ios`
2. **Actions** → **Build iOS (cloud Mac)** → **Run workflow**
3. Сборка идёт на `macos-14` в облаке GitHub

Без секретов получите **проверку компиляции**, не IPA на телефон.

### IPA на телефон (нужен сертификат один раз)

Один раз на **любом Mac** (или у знакомого): экспорт сертификата Development → добавить секреты в GitHub → workflow отдаст `.ipa` в Artifacts.

Секреты (Settings → Secrets):

- `APPLE_CERTIFICATE_BASE64` — `.p12` в base64
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_PROVISIONING_PROFILE_BASE64`
- `KEYCHAIN_PASSWORD` — любая строка

Подробнее: [GitHub Actions + iOS signing](https://docs.github.com/en/actions/deployment/deploying-xcode-applications)

---

## Способ D — Mac один раз (классика)

Если есть доступ к Mac хотя бы 10 минут:

1. Открыть `Sfera.xcodeproj` → Apple ID → **Run** на iPhone  
2. Или собрать IPA и дальше ставить с Windows через Sideloadly

---

## Способ E — виртуальная macOS на Windows

Технически возможно (VMware + образ macOS), но:

- тяжело настраивать;
- может нарушать лицензию Apple на не-Mac железе;
- Xcode часто тормозит.

**Не рекомендуем** — Codemagic или PWA проще.

---

## Что выбрать

| Цель | Решение |
|------|---------|
| Быстро потестить чат | **PWA** (Safari) |
| Нативная иконка, только Windows | **Codemagic** + Sideloadly |
| Полный контроль, есть Mac иногда | **Xcode Run** |
| CI из git | **GitHub Actions** |

---

## Expo / Flutter?

«С Windows собирают iOS» часто имеют в виду **Expo EAS** или **Flutter**:

```bash
eas build --platform ios
```

Сборка в облаке, с Windows. Но это **другой стек** — не наш Swift-проект. Для Sfera уже готов WebView-клиент; дублировать в Expo смысла мало.

---

## Итог

- **Напрямую на Windows** — только Android (`sfera_android`).
- **iOS с Windows** — через **облако** (Codemagic / GitHub Actions) или **PWA без сборки**.
- Это и имели в виду «можно собрать на Windows» — не локальный Xcode, а **облачный Mac** или **установка готового IPA**.
