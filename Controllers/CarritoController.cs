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
        public async Task<IActionResult> Agregar(int productId, int cantidad = 1)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null || product.Discontinued)
                return NotFound();

            if (cantidad < 1) cantidad = 1;

            var carrito = ObtenerCarrito();
            var item = carrito.FirstOrDefault(c => c.ProductId == productId);
            if (item != null)
                item.Quantity += cantidad;
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
        public IActionResult ActualizarCantidad(int productId, int cantidad)
        {
            var carrito = ObtenerCarrito();
            var item = carrito.FirstOrDefault(c => c.ProductId == productId);
            if (item != null)
            {
                if (cantidad <= 0)
                    carrito.Remove(item);
                else
                    item.Quantity = cantidad;
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
                TempData["Error"] = "El carrito está vacío.";
                return RedirectToAction(nameof(Index));
            }

            foreach (var item in carrito)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product == null || product.UnitsInStock < item.Quantity)
                {
                    TempData["Error"] = $"Stock insuficiente para '{item.ProductName}'. Disponible: {product?.UnitsInStock ?? 0}.";
                    return RedirectToAction(nameof(Index));
                }
            }

            var order = new Order
            {
                OrderDate = DateOnly.FromDateTime(DateTime.Today),
                ShipName  = User.Identity!.Name,
                ShipAddress = "Compra Online"
            };
            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            foreach (var item in carrito)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                _context.OrderDetails.Add(new OrderDetail
                {
                    OrderId = order.OrderId,
                    ProductId = item.ProductId,
                    UnitPrice = item.UnitPrice,
                    Quantity = (short)item.Quantity,
                    Discount = 0
                });
                product!.UnitsInStock = (short)(product.UnitsInStock.GetValueOrDefault() - item.Quantity);
                _context.Update(product);
            }
            await _context.SaveChangesAsync();

            GuardarCarrito(new List<CarritoItem>());
            return RedirectToAction(nameof(Confirmacion), new { orderId = order.OrderId });
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
    }
}
