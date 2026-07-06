# NorthwindApp — Actividad Voluntaria Segundo Parcial

Aplicación web desarrollada con **ASP.NET Core MVC (.NET 10)** y **PostgreSQL**, basada en la base de datos Northwind. Implementa autenticación con roles, CRUD de productos, consultas LINQ, carrito de compras con transacción atómica y publicación en modo Release.

---

## Tecnologías utilizadas

- ASP.NET Core MVC — .NET 10
- Entity Framework Core 10 — Database First
- PostgreSQL + Npgsql
- ASP.NET Core Identity (autenticación y roles)
- Bootstrap 5
- Razor Views

## Dependencias (paquetes NuGet)

| Paquete | Versión |
|---------|---------|
| Microsoft.AspNetCore.Identity.EntityFrameworkCore | 10.0.9 |
| Microsoft.AspNetCore.Identity.UI | 10.0.9 |
| Microsoft.EntityFrameworkCore.Design | 10.0.9 |
| Microsoft.EntityFrameworkCore.Tools | 10.0.9 |
| Npgsql.EntityFrameworkCore.PostgreSQL | 10.0.2 |
| Microsoft.VisualStudio.Web.CodeGeneration.Design | 10.0.2 |

---

## Estructura del proyecto

```
NorthwindApp/
├── Controllers/
│   ├── CarritoController.cs       # Carrito de compras (solo rol Customer)
│   ├── OrdersController.cs        # Gestión de órdenes
│   ├── ProductsController.cs      # CRUD + consultas LINQ
│   ├── CategoriesController.cs
│   └── SuppliersController.cs
├── Models/                        # Modelos generados por Database First
├── Data/
│   └── NorthwindContext.cs        # DbContext con Identity
├── Views/
│   ├── Carrito/                   # Carrito, Confirmación, MisOrdenes
│   ├── Products/                  # Listado, búsqueda, CRUD
│   └── Shared/_Layout.cshtml
├── wwwroot/                       # Archivos estáticos (CSS, JS)
├── publish/                       # Publicación Release generada
├── Program.cs                     # Configuración de servicios y middleware
├── appsettings.json               # Configuración (sin credenciales)
└── NorthwindApp.csproj
```

---

## Requisitos previos

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [PostgreSQL 14+](https://www.postgresql.org/download/)
- Base de datos Northwind restaurada en PostgreSQL

---

## Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/Lombeida2023/NorthwindAppActividadAdiccional.git
cd NorthwindAppActividadAdiccional
```

### 2. Configurar la cadena de conexión

Editar `appsettings.json` y reemplazar con los datos de tu servidor PostgreSQL:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=northwind;Username=TU_USUARIO;Password=TU_CONTRASENA"
  }
}
```

### 3. Restaurar dependencias

```bash
dotnet restore
```

---

## Comandos de ejecución

### Modo desarrollo

```bash
dotnet run
```

La aplicación estará disponible en: `http://localhost:5047`

### Modo Release (publicación)

```bash
dotnet publish -c Release -o ./publish
cd publish
dotnet NorthwindApp.dll
```

---

## Usuarios de prueba

Los siguientes usuarios se crean automáticamente al iniciar la aplicación por primera vez:

| Rol | Usuario | Contraseña |
|-----|---------|-----------|
| Admin | `admin@northwind.com` | *(configurada en Program.cs)* |
| Customer | `customer@northwind.com` | *(configurada en Program.cs)* |
| Employee | `employee@northwind.com` | *(configurada en Program.cs)* |

> Las contraseñas se configuran en `Program.cs` mediante variables de entorno o directamente en el código para entornos de desarrollo.

---

## Funcionalidades principales

- **CRUD de Productos** con eliminación lógica (`Discontinued = true`) y paginación
- **9 consultas LINQ**: productos más caros, búsqueda dinámica, por categoría, por proveedor, en pedidos, stock bajo, sin existencias, descontinuados, top 10 más comprados
- **Carrito de compras** con sesión del servidor (JSON)
- **Checkout con transacción atómica**: `BeginTransactionAsync` / `CommitAsync` / `RollbackAsync`
- **11 validaciones del servidor**: cantidad inválida, stock insuficiente, producto sin existencias, carrito vacío, re-verificación de stock, decimales, descontinuados, inexistente, sin autenticación, sin autorización, carrito vaciado
- **Historial de pedidos** por usuario (`MisOrdenes` / `MisOrdenDetalle`)
- **Control de acceso por roles**: Admin, Customer, Employee

---

## Evidencia de publicación Release

La carpeta `publish/` contiene la versión compilada en modo Release lista para producción, generada con:

```bash
dotnet publish -c Release -o ./publish
```
