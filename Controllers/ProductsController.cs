using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using NorthwindApp.Data;
using NorthwindApp.Models;

namespace NorthwindApp.Controllers
{
    public class ProductsController : Controller
    {
        private readonly NorthwindContext _context;

        public ProductsController(NorthwindContext context)
        {
            _context = context;
        }

        // GET: Products — listado con paginación, solo activos (eliminación lógica)
        public async Task<IActionResult> Index(int page = 1)
        {
            int pageSize = 10;
            var query = _context.Products
                .Where(p => !p.Discontinued)
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .OrderBy(p => p.ProductName);

            int total = await query.CountAsync();
            var productos = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            ViewBag.Page = page;
            ViewBag.TotalPages = (int)Math.Ceiling(total / (double)pageSize);
            return View(productos);
        }

        // LINQ 1: 10 productos más caros
        public async Task<IActionResult> MasCaros()
        {
            var productos = await _context.Products
                .Where(p => !p.Discontinued)
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .OrderByDescending(p => p.UnitPrice)
                .Take(10)
                .ToListAsync();
            ViewBag.Titulo = "10 Productos Más Caros";
            return View("Lista", productos);
        }

        // LINQ 2: productos cuyo nombre contiene una palabra (búsqueda dinámica)
        public async Task<IActionResult> BuscarPorNombre(string? q)
        {
            string keyword = string.IsNullOrWhiteSpace(q) ? "" : q.Trim();
            var productos = await _context.Products
                .Where(p => p.ProductName.ToLower().Contains(keyword.ToLower()) && !p.Discontinued)
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .OrderBy(p => p.ProductName)
                .ToListAsync();
            ViewBag.Titulo = string.IsNullOrEmpty(keyword)
                ? "Todos los productos disponibles"
                : $"Productos que contienen: '{keyword}'";
            ViewBag.SearchQuery = keyword;
            return View("BuscarPorNombre", productos);
        }

        // LINQ 3: productos con Join por categoría específica
        public async Task<IActionResult> PorCategoria()
        {
            var productos = await (
                from p in _context.Products
                join c in _context.Categories on p.CategoryId equals c.CategoryId
                join s in _context.Suppliers on p.SupplierId equals s.SupplierId into ps
                from s in ps.DefaultIfEmpty()
                where c.CategoryName == "Beverages" && !p.Discontinued
                select new Product
                {
                    ProductId = p.ProductId,
                    ProductName = p.ProductName,
                    UnitPrice = p.UnitPrice,
                    UnitsInStock = p.UnitsInStock,
                    Category = c,
                    Supplier = s
                }).ToListAsync();

            ViewBag.Titulo = "Productos de la categoría: Beverages (Join)";
            return View("Lista", productos);
        }

        // LINQ 4: productos por proveedor específico
        public async Task<IActionResult> PorProveedor()
        {
            var productos = await _context.Products
                .Include(p => p.Supplier)
                .Include(p => p.Category)
                .Where(p => p.Supplier!.CompanyName == "Exotic Liquids" && !p.Discontinued)
                .ToListAsync();
            ViewBag.Titulo = "Productos del proveedor: Exotic Liquids";
            return View("Lista", productos);
        }

        // LINQ 5: productos en pedidos (a través de OrderDetails)
        public async Task<IActionResult> EnPedidos()
        {
            var productos = await _context.Products
                .Where(p => p.OrderDetails.Any() && !p.Discontinued)
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .OrderBy(p => p.ProductName)
                .Take(10)
                .ToListAsync();
            ViewBag.Titulo = "Productos que aparecen en pedidos";
            return View("Lista", productos);
        }

        // LINQ 6: productos con stock bajo (condición compuesta)
        public async Task<IActionResult> StockBajo()
        {
            var productos = await _context.Products
                .Where(p => !p.Discontinued && p.UnitsInStock < p.ReorderLevel && p.UnitsInStock > 0)
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .OrderBy(p => p.UnitsInStock)
                .ToListAsync();
            ViewBag.Titulo = "Productos con stock bajo (stock < nivel de reorden)";
            return View("Lista", productos);
        }

        // LINQ 7: productos sin existencias (stock = 0, no descontinuados)
        public async Task<IActionResult> SinExistencias()
        {
            var productos = await _context.Products
                .Where(p => !p.Discontinued && p.UnitsInStock == 0)
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .OrderBy(p => p.ProductName)
                .ToListAsync();
            ViewBag.Titulo = "Productos sin existencias (stock = 0)";
            return View("Lista", productos);
        }

        // LINQ 8: productos descontinuados (solo Admin)
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Descontinuados()
        {
            var productos = await _context.Products
                .Where(p => p.Discontinued)
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .OrderBy(p => p.ProductName)
                .ToListAsync();
            ViewBag.Titulo = "Productos descontinuados";
            return View("Lista", productos);
        }

        // LINQ 9: 10 productos más comprados (por cantidad vendida en OrderDetails)
        public async Task<IActionResult> MasComprados()
        {
            // Obtener IDs ordenados por cantidad total vendida
            var topIds = await _context.OrderDetails
                .GroupBy(od => od.ProductId)
                .OrderByDescending(g => g.Sum(od => (int)od.Quantity))
                .Take(10)
                .Select(g => g.Key)
                .ToListAsync();

            var productos = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .Where(p => topIds.Contains(p.ProductId))
                .ToListAsync();

            // Reordenar según ranking de ventas
            var ordenados = topIds
                .Select(id => productos.FirstOrDefault(p => p.ProductId == id))
                .Where(p => p != null)
                .ToList();

            ViewBag.Titulo = "10 Productos Más Comprados";
            return View("Lista", ordenados);
        }

        // GET: Products/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null) return NotFound();

            var product = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .FirstOrDefaultAsync(m => m.ProductId == id);

            if (product == null) return NotFound();
            return View(product);
        }

        // GET: Products/Create — protegido solo para Admin
        [Authorize(Roles = "Admin")]
        public IActionResult Create()
        {
            ViewData["CategoryId"] = new SelectList(_context.Categories, "CategoryId", "CategoryName");
            ViewData["SupplierId"] = new SelectList(_context.Suppliers, "SupplierId", "CompanyName");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Create([Bind("ProductName,SupplierId,CategoryId,QuantityPerUnit,UnitPrice,UnitsInStock,UnitsOnOrder,ReorderLevel")] Product product)
        {
            if (ModelState.IsValid)
            {
                product.Discontinued = false;
                _context.Add(product);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["CategoryId"] = new SelectList(_context.Categories, "CategoryId", "CategoryName", product.CategoryId);
            ViewData["SupplierId"] = new SelectList(_context.Suppliers, "SupplierId", "CompanyName", product.SupplierId);
            return View(product);
        }

        // GET: Products/Edit/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();

            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            ViewData["CategoryId"] = new SelectList(_context.Categories, "CategoryId", "CategoryName", product.CategoryId);
            ViewData["SupplierId"] = new SelectList(_context.Suppliers, "SupplierId", "CompanyName", product.SupplierId);
            return View(product);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Edit(int id, [Bind("ProductId,ProductName,SupplierId,CategoryId,QuantityPerUnit,UnitPrice,UnitsInStock,UnitsOnOrder,ReorderLevel,Discontinued")] Product product)
        {
            if (id != product.ProductId) return NotFound();

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(product);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ProductExists(product.ProductId)) return NotFound();
                    throw;
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["CategoryId"] = new SelectList(_context.Categories, "CategoryId", "CategoryName", product.CategoryId);
            ViewData["SupplierId"] = new SelectList(_context.Suppliers, "SupplierId", "CompanyName", product.SupplierId);
            return View(product);
        }

        // GET: Products/Delete/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null) return NotFound();

            var product = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .FirstOrDefaultAsync(m => m.ProductId == id);

            if (product == null) return NotFound();
            return View(product);
        }

        // Eliminación LÓGICA: marca Discontinued = true
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product != null)
            {
                product.Discontinued = true;
                _context.Update(product);
                await _context.SaveChangesAsync();
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: Products/IncrementarStock/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> IncrementarStock(int? id)
        {
            if (id == null) return NotFound();
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();
            return View(product);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> IncrementarStock(int id, int cantidad)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            if (cantidad <= 0)
            {
                ModelState.AddModelError("", "La cantidad debe ser mayor a 0.");
                return View(product);
            }

            product.UnitsInStock = (short)(product.UnitsInStock.GetValueOrDefault() + cantidad);
            _context.Update(product);
            await _context.SaveChangesAsync();
            TempData["Mensaje"] = $"Stock de '{product.ProductName}' incrementado en {cantidad}. Nuevo stock: {product.UnitsInStock}.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Products/ReducirStock/5
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ReducirStock(int? id)
        {
            if (id == null) return NotFound();
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();
            return View(product);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ReducirStock(int id, int cantidad)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            if (cantidad <= 0)
            {
                ModelState.AddModelError("", "La cantidad debe ser mayor a 0.");
                return View(product);
            }

            if (product.UnitsInStock < cantidad)
            {
                ModelState.AddModelError("", $"Stock insuficiente. Stock actual: {product.UnitsInStock}.");
                return View(product);
            }

            product.UnitsInStock = (short)(product.UnitsInStock.GetValueOrDefault() - cantidad);
            _context.Update(product);
            await _context.SaveChangesAsync();
            TempData["Mensaje"] = $"Stock de '{product.ProductName}' reducido en {cantidad}. Nuevo stock: {product.UnitsInStock}.";
            return RedirectToAction(nameof(Index));
        }

        private bool ProductExists(int id)
        {
            return _context.Products.Any(e => e.ProductId == id);
        }
    }
}
