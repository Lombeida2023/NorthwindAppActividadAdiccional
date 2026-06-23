using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NorthwindApp.Data;
using NorthwindApp.Models;

namespace NorthwindApp.Controllers
{
    [Authorize(Roles = "Admin")]
    public class OrdersController : Controller
    {
        private readonly NorthwindContext _context;

        public OrdersController(NorthwindContext context)
        {
            _context = context;
        }

        // GET: Orders — todas las órdenes
        public async Task<IActionResult> Index()
        {
            var pedidos = await _context.Orders
                .Include(o => o.Customer)
                .Include(o => o.Employee)
                .Include(o => o.OrderDetails)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();
            return View(pedidos);
        }

        // GET: Orders/ComprasPorCliente
        public async Task<IActionResult> ComprasPorCliente()
        {
            var compras = await _context.Orders
                .Include(o => o.OrderDetails)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();

            var porCliente = compras
                .GroupBy(o => o.ShipName ?? o.CustomerId ?? "Desconocido")
                .Select(g => new
                {
                    Cliente = g.Key,
                    TotalOrdenes = g.Count(),
                    TotalComprado = g.Sum(o => o.OrderDetails.Sum(od => od.UnitPrice * od.Quantity)),
                    Ordenes = g.ToList()
                })
                .OrderByDescending(g => g.TotalComprado)
                .ToList();

            ViewBag.ComprasPorCliente = porCliente;
            return View();
        }

        // GET: Orders/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null) return NotFound();

            var order = await _context.Orders
                .Include(o => o.Customer)
                .Include(o => o.Employee)
                .Include(o => o.ShipViaNavigation)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(m => m.OrderId == id);

            if (order == null) return NotFound();
            return View(order);
        }

        // GET: Orders/Create
        public IActionResult Create()
        {
            ViewData["CustomerId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Customers, "CustomerId", "CompanyName");
            ViewData["EmployeeId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Employees, "EmployeeId", "LastName");
            ViewData["ShipVia"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Shippers, "ShipperId", "CompanyName");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("OrderId,CustomerId,EmployeeId,OrderDate,RequiredDate,ShippedDate,ShipVia,Freight,ShipName,ShipAddress,ShipCity,ShipRegion,ShipPostalCode,ShipCountry")] Order order)
        {
            if (ModelState.IsValid)
            {
                _context.Add(order);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["CustomerId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Customers, "CustomerId", "CompanyName", order.CustomerId);
            ViewData["EmployeeId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Employees, "EmployeeId", "LastName", order.EmployeeId);
            ViewData["ShipVia"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Shippers, "ShipperId", "CompanyName", order.ShipVia);
            return View(order);
        }

        // GET: Orders/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();
            var order = await _context.Orders.FindAsync(id);
            if (order == null) return NotFound();
            ViewData["CustomerId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Customers, "CustomerId", "CompanyName", order.CustomerId);
            ViewData["EmployeeId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Employees, "EmployeeId", "LastName", order.EmployeeId);
            ViewData["ShipVia"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Shippers, "ShipperId", "CompanyName", order.ShipVia);
            return View(order);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("OrderId,CustomerId,EmployeeId,OrderDate,RequiredDate,ShippedDate,ShipVia,Freight,ShipName,ShipAddress,ShipCity,ShipRegion,ShipPostalCode,ShipCountry")] Order order)
        {
            if (id != order.OrderId) return NotFound();

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(order);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!OrderExists(order.OrderId)) return NotFound();
                    throw;
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["CustomerId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Customers, "CustomerId", "CompanyName", order.CustomerId);
            ViewData["EmployeeId"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Employees, "EmployeeId", "LastName", order.EmployeeId);
            ViewData["ShipVia"] = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(_context.Shippers, "ShipperId", "CompanyName", order.ShipVia);
            return View(order);
        }

        // GET: Orders/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null) return NotFound();
            var order = await _context.Orders
                .Include(o => o.Customer)
                .Include(o => o.Employee)
                .FirstOrDefaultAsync(m => m.OrderId == id);
            if (order == null) return NotFound();
            return View(order);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order != null)
                _context.Orders.Remove(order);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool OrderExists(int id)
        {
            return _context.Orders.Any(e => e.OrderId == id);
        }
    }
}
