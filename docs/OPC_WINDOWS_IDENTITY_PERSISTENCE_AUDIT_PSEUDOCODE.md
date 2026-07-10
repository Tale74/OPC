# OPC Windows Identity Persistence Audit Pseudocode

Status: audit-only source map for the reported Windows Administrator persistence incident.

## Windows database-path resolution

```text
BUILD_VARIANT is read from dart-define BUILD_VARIANT
IF BUILD_VARIANT absent/unknown:
    build variant = PRODUCTION
    database name = opc_v4_release

IF BUILD_VARIANT == WINDOWS:
    database name = opc_v4_release

IF BUILD_VARIANT == WINDOWS_TEST:
    database name = opc_v4_windows_test

drift opens:
    driftDatabase(name: database name)

drift_flutter/path_provider resolves the platform app documents location
database file is expected as:
    <application documents directory>/<database name>.sqlite
```

Presentation POTPUN mode is separate from `BUILD_VARIANT`.

```text
OPC_PRESENTATION_POTPUN=true:
    changes entitlement resolver result
    does not change kBuildVariant
    does not change kDatabaseName
    does not choose a different SQLite file
```

## Startup/bootstrap flow

```text
main:
    initialize Flutter bindings
    initialize window manager on desktop
    initialize Serbian date formatting
    create AppDatabase
    run OpcApp

OpcApp.initState:
    create AuthRepository using same AppDatabase
    create SessionService in memory
    create settings/predmet/reminder repositories using same AppDatabase
    resolve entitlement through OpcRuntimeEntitlementResolver

StartRouter:
    wait for entitlement
    IF session has user:
        check mustChangePin
        show ForcedPinChange or ListaPredmeta
    ELSE:
        wait for authRepo.hasKorisnika()
        IF no active users:
            show FirstLaunchScreen
        ELSE:
            show LoginScreen
```

## User persistence

```text
korisnici table:
    id
    imePrezime
    uloga
    pinHash
    aktivan
    datumKreiranja

FirstLaunchScreen:
    calls AuthRepository.kreirajPrvogAdmina

kreirajPrvogAdmina:
    insert korisnici row with uloga ADMINISTRATOR
    store hashed PIN in same row
    update PIN security metadata columns
    mark mustChangePin false
    return inserted row
    session.prijavi(row)
```

No source-owned last-selected user persistence was found.

## TEST creation/selection

```text
production database create:
    creates schema
    seeds catalog/templates/singletons/security settings
    does not seed korisnici row named TEST

test files:
    may create Test Administrator / Test Savetnik synthetic users

source audit status:
    TEST is test-data vocabulary in tests
    no production bootstrap TEST user seed found
```

## Login/user-selection

```text
LoginScreen.initState:
    futureKorisnici = authRepo.sviKorisnici(samoAktivni: true)

LoginScreen user list:
    displays every active korisnici row sorted by imePrezime
    no role/package/license filter found

PIN step:
    selected user id + entered PIN hash must match active row

Promeni savetnika:
    clears local selected user state
    returns to same loaded active-user list
```

## Forgotten-PIN path

```text
Zaboravljen PIN:
    opens ForgotPinRecoveryDialog

Dialog bootstrap:
    hasRecoveryCode = authRepo.imaPodesenSigurnosniKod()
    administrators = authRepo.aktivniAdministratori()

IF no recovery code:
    recovery is unavailable

IF no active administrators:
    recovery is unavailable

IF one/more active administrators and valid security code:
    reset selected/existing active Administrator PIN
    set mustChangePin true
```

Forgotten PIN can list active administrators independently of the currently
selected login user, but it cannot recover an administrator row that is absent
from the opened database or inactive.

## License/entitlement separation

```text
normal startup:
    evaluate installed local license
    entitlement controls module availability

presentation startup:
    if OPC_PRESENTATION_POTPUN=true:
        return presentationOwner / POTPUN entitlement
        do not evaluate local license bootstrap

entitlement policy:
    does not receive AppDatabase
    does not query korisnici
    does not write korisnici
    does not change database name
```

## Unresolved incident branches

```text
IF expected Administrator exists in affected sqlite:
    investigate active flag, role, PIN state, recovery material, selected database

IF expected Administrator absent from affected sqlite:
    investigate whether a different database path was opened
    investigate whether original creation completed and committed
    investigate copied release / Windows profile / shortcut context

IF only TEST exists:
    determine whether TEST was manually created, imported, or came from a different database/build

IF recovery unavailable:
    determine whether security_settings has recovery material
    determine whether any active Administrator row exists
```

Do not promote any branch to root cause without client-side copied evidence.
