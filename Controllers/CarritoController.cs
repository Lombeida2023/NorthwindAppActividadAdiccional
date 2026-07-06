using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NorthwindApp.Data;
using NorthwindApp.Models;
using System.Text.Json;

namespace NorthwindApp.Controllers
{
    [Authorize(Roles = "Customer")]
    public class CarritoController : Controller
    {
        private readonly NorthwindContext _context;
        private const string CartKey = "Carrito";

        public CarritoController(NorthwindContext context)
        {
            _context = context;
        }

        private List<CarritoItem> ObtenerCarrito()
        {
            var json = HttpContext.Session.GetString(CartKey);
            return json == null ? new List<CarritoItem>() : JsonSerializer.Deserialize<List<CarritoItem>>(json)!;
        }

        private void GuardarCarrito(List<CarritoItem> carrito)
        {
            HttpContext.Session.SetString(CartKey, JsonSerializer.Serialize(carrito));
        }

        public IActionResult Index()
        {
            return View(ObtenerCarrito());
        }

        [HttpPost]
        public async Task<IActionResult> Agregar(int productId, int cantidad)
        {
            // Validación: cantidad debe ser un entero positivo
            if (cantidad <= 0)
            {
                TempData["Error"] = "La cantidad debe ser mayor a cero.";
                return RedirectToAction("Index", "Products");
            }

            // Verificar que el producto existe en BD
            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.ProductId == productId);

            if (product == null)
            {
                TempData["Error"] = "El producto no existe.";
                return RedirectToAction("Index", "Products");
            }

            if (product.Discontinued)
            {
                TempData["Error"] = $"'{product.ProductName}' está descontinuado y no puede comprarse.";
                return RedirectToAction("Index", "Products");
            }

            if (product.UnitsInStock <= 0)
            {
                TempData["Error"] = $"'{product.ProductName}' no tiene existencias disponibles.";
                return RedirectToAction("Index", "Products");
            }

            var carrito = ObtenerCarrito();
            var itemExistente = carrito.FirstOrDefault(c => c.ProductId == productId);
            int cantidadTotal = (itemExistente?.Quantity ?? 0) + cantidad;

            if (cantidadTotal > product.UnitsInStock)
            {
                TempData["Error"] = $"Stock insuficiente para '{product.ProductName}'. " +
                                    $"Disponible: {product.UnitsInStock}, solicitado: {cantidadTotal}.";
                return RedirectToAction("Index", "Products");
            }

            if (itemExistente != null)
                itemExistente.Quantity += cantidad;
            else
                carrito.Add(new CarritoItem
                {
                    ProductId = product.ProductId,
                    ProductName = product.ProductName,
                    UnitPrice = product.UnitPrice ?? 0,
                    Quantity = cantidad
                });

            GuardarCarrito(carrito);
            TempData["Mensaje"] = $"'{product.ProductName}' agregado al carrito.";
            return RedirectToAction("Index", "Products");
        }

        [HttpPost]
        public IActionResult Eliminar(int productId)
        {
            var carrito = ObtenerCarrito();
            carrito.RemoveAll(c => c.ProductId == productId);
            GuardarCarrito(carrito);
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> ActualizarCantidad(int productId, int cantidad)
        {
            var carrito = ObtenerCarrito();
            var item = carrito.FirstOrDefault(c => c.ProductId == productId);

            if (item != null)
            {
                if (cantidad <= 0)
                {
                    carrito.Remove(item);
                }
                else
                {
                    // Validar contra stock actual en BD
                    var product = await _context.Products.FindAsync(productId);
                    if (product != null && cantidad > product.UnitsInStock)
                    {
                        TempData["Error"] = $"Stock insuficiente para '{item.ProductName}'. Disponible: {product.UnitsInStock}.";
                        GuardarCarrito(carrito);
                        return RedirectToAction(nameof(Index));
                    }
                    item.Quantity = cantidad;
                }
            }

            GuardarCarrito(carrito);
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> Confirmar()
        {
            var carrito = ObtenerCarrito();

            if (!carrito.Any())
            {
                TempData["Error"] = "El carrito está vacío. Agregue productos antes de confirmar.";
                return RedirectToAction(nameof(Index));
            }

            // Obtener productos frescos desde BD para validar stock actual
            var productIds = carrito.Select(c => c.ProductId).ToList();
            var productos = await _context.Products
                .Where(p => productIds.Contains(p.ProductId))
                .ToListAsync();

            foreach (var item in carrito)
            {
                var product = productos.FirstOrDefault(p => p.ProductId == item.ProductId);

                if (product == null)
                {
                    TempData["Error"] = $"El producto '{item.ProductName}' ya no existe en el sistema.";
                    return RedirectToAction(nameof(Index));
                }

                if (product.Discontinued)
                {
                    TempData["Error"] = $"'{product.ProductName}' fue descontinuado y no puede comprarse.";
                    return RedirectToAction(nameof(Index));
                }

                // Re-verificar stock (otro usuario pudo haber comprado mientras tanto)
                if (product.UnitsInStock < item.Quantity)
                {
                    TempData["Error"] = $"Stock insuficiente para '{product.ProductName}'. " +
                                        $"Disponible: {product.UnitsInStock}, solicitado: {item.Quantity}.";
                    return RedirectToAction(nameof(Index));
                }
            }

            // Usar transacción para que Order + OrderDetails + stock sean atómicos
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var order = new Order
                {
                    OrderDate = DateOnly.FromDateTime(DateTime.Today),
                    ShipName = User.Identity!.Name,
                    ShipAddress = "Compra Online"
                };
                _context.Orders.Add(order);
                await _context.SaveChangesAsync();

                foreach (var item in carrito)
                {
                    var product = productos.First(p => p.ProductId == item.ProductId);

                    // Precio obtenido de BD, no del carrito (evita manipulación del cliente)
                    _context.OrderDetails.Add(new OrderDetail
                    {
                        OrderId = order.OrderId,
                        ProductId = item.ProductId,
                        UnitPrice = product.UnitPrice ?? 0,
                        Quantity = (short)item.Quantity,
                        Discount = 0
                    });

                    product.UnitsInStock = (short)(product.UnitsInStock.GetValueOrDefault() - item.Quantity);
                    _context.Update(product);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                GuardarCarrito(new List<CarritoItem>());
                return RedirectToAction(nameof(Confirmacion), new { orderId = order.OrderId });
            }
            catch (Exception)
            {
                await transaction.RollbackAsync();
                TempData["Error"] = "Ocurrió un error al procesar la compra. Por favor, intente nuevamente.";
                return RedirectToAction(nameof(Index));
            }
        }

        public async Task<IActionResult> Confirmacion(int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null) return NotFound();
            return View(order);
        }

        // Mis órdenes: el cliente consulta su historial de compras
        public async Task<IActionResult> MisOrdenes()
        {
            var userName = User.Identity!.Name;

            var ordenes = await _context.Orders
                .Include(o => o.OrderDetails)
                .Where(o => o.ShipName == userName)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();

            return View(ordenes);
        }

        // Detalle de una orden propia del cliente
        public async Task<IActionResult> MisOrdenDetalle(int orderId)
        {
            var userName = User.Identity!.Name;

            var orden = await _context.Orders
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == orderId && o.ShipName == userName);

            if (orden == null) return NotFound();
            return View(orden);
        }
    }
}
