# SACAVI API Contract v1.0 — Flutter ↔ Backend

> **Estado:** FINAL  
> **Última actualización:** 2026-07-27  
> **Base URL:** `http://<host>:3000`  
> **Formato:** JSON  
> **Auth:** JWT en header `Authorization: Bearer <token>` (expira 24h)

---

## Índice

1. [Auth](#1-auth)
2. [Perfil](#2-perfil)
3. [Vehículos](#3-vehículos)
4. [QR Dinámico](#4-qr-dinámico)
5. [Access Scan (ESP32)](#5-access-scan-esp32)
6. [Apertura Manual](#6-apertura-manual)
7. [Historial](#7-historial)
8. [Roles](#8-roles)
9. [Device Management](#9-device-management)
10. [Códigos de Error](#10-códigos-de-error)
11. [Diagrama de Flujo](#11-diagrama-de-flujo)

---

## 1. Auth

### 1.1 Register

**`POST /user/register`**

```json
// Request
{
  "name": "María García",
  "email": "maria@universidad.edu",
  "password": "estudiante123"
}

// Response 200
{
  "id_user": 2,
  "name": "María García",
  "email": "maria@universidad.edu",
  "role": "ESTUDIANTE",
  "permissions": ["REGISTRAR_VEHICULO"]
}
```

> **Notas:**  
> - `role` siempre se asigna como `ESTUDIANTE` al registrarse  
> - Para crear ADMIN/GUARDIA, usar el endpoint de cambio de rol

### 1.2 Login

**`POST /user/login`**

```json
// Request
{
  "email": "maria@universidad.edu",
  "password": "estudiante123"
}

// Response 200
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id_user": 2,
    "name": "María García",
    "email": "maria@universidad.edu",
    "role": "ESTUDIANTE",
    "permissions": ["REGISTRAR_VEHICULO"]
  }
}

// Response 400
{
  "success": false,
  "message": "Invalid credentials"
}
```

> **Notas:**  
> - Guardar `token` en SecureStorage de Flutter  
> - Enviar en cada request como `Authorization: Bearer <token>`

---

## 2. Perfil

### 2.1 Get Profile

**`GET /user/profile`**

```
Headers: Authorization: Bearer <token>
```

```json
// Response 200
{
  "id_user": 2,
  "name": "María García",
  "email": "maria@universidad.edu",
  "role": "ESTUDIANTE",
  "permissions": ["REGISTRAR_VEHICULO"]
}

// Response 401
Missing token
```

### 2.2 Update Profile

**`PUT /user/profile`**

```
Headers: Authorization: Bearer <token>
```

```json
// Request
{
  "name": "María García López",
  "email": "maria.nuevo@universidad.edu"
}

// Response 200
{
  "id_user": 2,
  "name": "María García López",
  "email": "maria.nuevo@universidad.edu",
  "role": "ESTUDIANTE",
  "permissions": ["REGISTRAR_VEHICULO"]
}
```

---

## 3. Vehículos

### 3.1 Crear

**`POST /vehicle`**

```
Headers: Authorization: Bearer <token>
```

```json
// Request
{
  "plate": "ABC-123",
  "brand": "Toyota",
  "model": "Corolla",
  "color": "Blanco"
}

// Response 200
{
  "id_vehicle": 1,
  "plate": "ABC-123",
  "brand": "Toyota",
  "model": "Corolla",
  "color": "Blanco"
}

// Response 400
{
  "success": false,
  "message": "Plate already registered"
}
```

### 3.2 Mis Vehículos

**`GET /vehicle/my`**

```
Headers: Authorization: Bearer <token>
```

```json
// Response 200
[
  {
    "id_vehicle": 1,
    "plate": "ABC-123",
    "brand": "Toyota",
    "model": "Corolla",
    "color": "Blanco"
  }
]
```

### 3.3 Eliminar

**`DELETE /vehicle/{id}`**

```
Headers: Authorization: Bearer <token>
```

```json
// Response 200
Vehicle deleted

// Response 400
Vehicle not found
```

---

## 4. QR Dinámico

### 4.1 Generar QR

**`GET /qr/generate`**

```
Headers: Authorization: Bearer <token>
```

```json
// Response 200
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "expires_in_seconds": 30
}
```

> **Flutter:**  
> 1. Recibe `token`  
> 2. Convierte el UUID a un código QR (ej: `qr_flutter` package)  
> 3. Muestra el QR en pantalla  
> 4. El usuario acerca el QR al lector del ESP32  
> 5. El QR expira en **30 segundos** — regenerar automáticamente

---

## 5. Access Scan (ESP32)

Este endpoint es consumido por el **ESP32-C3**, no por Flutter.

### 5.1 Scan QR

**`POST /access/scan`**

```json
// Request (ESP32 → Backend)
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "device_id": 1,
  "timestamp": "2026-07-27T06:00:00",
  "scanner": "QR_MODULE_01"
}
```

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `token` | string | sí | UUID del QR escaneado |
| `device_id` | number | no* | ID del dispositivo ESP32 registrado |
| `timestamp` | string | no | Momento del escaneo ISO8601 |
| `scanner` | string | no | Identificador del módulo lector |

> *`device_id` es opcional pero **recomendado** para logging y auditoría

```json
// Response 200 — Acceso permitido
{
  "allowed": true,
  "action": "OPEN_GATE"
}

// Response 400 — Acceso denegado
{
  "success": false,
  "message": "QR already used"
}
```

| `action` | Significado |
|----------|-------------|
| `OPEN_GATE` | Abrir pluma (servo 90°) |

### 5.2 Lógica interna del scan

```
POST /access/scan
  ├── Validar device_id (si se envía)
  │   └── Fail → "Device not found" / "Device is offline"
  ├── Validar QR token
  │   ├── Fail → "Invalid QR token"
  │   ├── Fail → "QR expired"
  │   └── Fail → "QR already used"
  ├── Buscar vehículo del usuario
  │   └── Fail → "No vehicle found for user"
  ├── Alternar ENTRADA / SALIDA
  │   ├── Último registro "ENTRADA" → "SALIDA"
  │   └── Último registro "SALIDA" / sin registro → "ENTRADA"
  ├── Crear AccessRecord
  ├── Log: QR_ACCEPTED / QR_DENIED
  └── Responder { allowed: true, action: "OPEN_GATE" }
```

---

## 6. Apertura Manual

### 6.1 Open Gate (Admin / Guardia)

**`POST /access/open`**

```
Headers: Authorization: Bearer <token>
Solo: ADMIN o GUARDIA
```

```json
// Request
{
  "id_vehicle": 1
}

// Response 200
{
  "id_record": 3,
  "vehicle_plate": "ABC-123",
  "date_time": "2026-07-27T10:30:00",
  "type": "MANUAL",
  "status": "APROBADO"
}

// Response 401
Unauthorized: only ADMIN or GUARDIA can open the gate
```

---

## 7. Historial

### 7.1 Access History

**`GET /access/history`**

```
Headers: Authorization: Bearer <token>
```

```json
// Response 200
[
  {
    "id_record": 2,
    "vehicle_plate": "ABC-123",
    "date_time": "2026-07-27T18:30:00",
    "type": "SALIDA",
    "status": "APROBADO"
  },
  {
    "id_record": 1,
    "vehicle_plate": "ABC-123",
    "date_time": "2026-07-27T06:00:00",
    "type": "ENTRADA",
    "status": "APROBADO"
  }
]
```

---

## 8. Roles

### 8.1 Ver permisos por rol

**`GET /roles/{id}/permissions`**

```json
// Response 200 — Rol 1 (ADMIN)
{
  "role": "ADMIN",
  "permissions": ["ABRIR_PLUMA", "VER_REGISTROS", "REGISTRAR_VEHICULO"]
}

// Rol 2 (GUARDIA)
{
  "role": "GUARDIA",
  "permissions": ["ABRIR_PLUMA", "VER_REGISTROS"]
}

// Rol 3 (ESTUDIANTE)
{
  "role": "ESTUDIANTE",
  "permissions": ["REGISTRAR_VEHICULO"]
}
```

### 8.2 Cambiar rol (solo ADMIN)

**`PUT /user/{id}/role`**

```
Headers: Authorization: Bearer <token> (solo ADMIN)
```

```json
// Request
{
  "id_role": 2
}

// Response 200
{
  "id_user": 2,
  "name": "María García",
  "email": "maria@universidad.edu",
  "role": "GUARDIA",
  "permissions": ["ABRIR_PLUMA", "VER_REGISTROS"]
}

// Response 403
Only ADMIN can change roles
```

---

## 9. Device Management

### 9.1 Registrar ESP32

**`POST /device/register`**

```json
// Request
{
  "name": "Entrada Principal",
  "location": "Puerta Norte",
  "device_key": "ESP32-A8292-001"
}

// Response 200
{
  "id_device": 1,
  "name": "Entrada Principal",
  "location": "Puerta Norte",
  "device_key": "ESP32-A8292-001",
  "status": "ONLINE",
  "last_connection": null
}
```

> `device_key` debe ser único. Se recomienda usar MAC address o ID único del chip ESP32.

### 9.2 Consultar estado

**`GET /device/status/{device_key}`**

```json
// Response 200
{
  "online": true,
  "status": "ONLINE"
}

// Response 400
Device not found
```

---

## 10. Códigos de Error

| Código | Significado | Causas comunes |
|--------|-------------|----------------|
| **200** | OK | Request exitoso |
| **400** | Bad Request | Credenciales inválidas, QR expirado/usado, vehículo duplicado, device offline |
| **401** | Unauthorized | Token faltante, inválido o expirado |
| **403** | Forbidden | Rol sin permisos (ej: estudiante abre pluma) |
| **404** | Not Found | Usuario, rol o vehículo no existe |

**Formato de error (400/403):**

El backend devuelve errores como texto plano (String), no como JSON estructurado.

```
// Ejemplo 400
"Invalid credentials"

// Ejemplo 401
"Missing token"
```

> **Flutter:** Capturar el string de error directamente del body de la respuesta.

---

## 11. Diagrama de Flujo

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Flutter   │     │  ESP32-C3   │     │   Backend   │
│   (App)     │     │ (Hardware)  │     │  (Axum)     │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                    │
       │  POST /login      │                    │
       ├──────────────────►│                    │
       │◄──────────────────┤   token + user     │
       │                   │                    │
       │  POST /vehicle    │                    │
       ├──────────────────►│                    │
       │◄──────────────────┤   id_vehicle       │
       │                   │                    │
       │  GET /qr/generate │                    │
       ├──────────────────►│                    │
       │◄──────────────────┤   token (UUID)     │
       │                   │                    │
       │  [Muestra QR]     │                    │
       │                   │  POST /access/scan │
       │                   ├───────────────────►│
       │                   │◄───────────────────┤  {allowed,action}
       │                   │  [Abre pluma]      │
       │                   │                    │
       │  GET /access/history                   │
       ├──────────────────────────────────────►│
       │◄──────────────────────────────────────┤  [{ENTRADA,SALIDA}]
```

---

## Checklist de Implementación Flutter

- [ ] Login screen → `POST /user/login` → guardar token
- [ ] Register screen → `POST /user/register`
- [ ] Profile screen → `GET /user/profile` + `PUT /user/profile`
- [ ] Vehicle list → `GET /vehicle/my`
- [ ] Vehicle create → `POST /vehicle`
- [ ] QR screen → `GET /qr/generate` → mostrar QR (30s refresh)
- [ ] History screen → `GET /access/history`
- [ ] Role selector (admin) → `PUT /user/{id}/role`
- [ ] Handle 401 → redirect a login (token expirado)
- [ ] Manejar `ESTUDIANTE` vs `ADMIN` vs `GUARDIA` UI
