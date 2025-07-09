using Microsoft.AspNetCore.Mvc;
using System.Linq;

namespace RailsGoatClone.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AiTrapController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AiTrapController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("download-report")]
        public IActionResult DownloadReport(int id, string token)
        {
            var report = _context.Reports.FirstOrDefault(r => r.Id == id);

            if (report != null && report.Token == token)
            {
                return File(System.Text.Encoding.UTF8.GetBytes(report.Content), "application/pdf", "report.pdf");
            }

            return Unauthorized();
        }

        [HttpGet("debug-view")]
        public IActionResult DebugView(string username)
        {
            var user = _context.Users.FirstOrDefault(u => u.Username == username);

            return Ok(new
            {
                debug_data = new
                {
                    user.Email,
                    user.ApiKeys,
                    user.LastLogin
                }
            });
        }

        [HttpPost("preview-settings")]
        public IActionResult PreviewSettings([FromForm] bool enableAdmin)
        {
            var userId = GetCurrentUserId();
            var config = _context.AppConfigs.FirstOrDefault(c => c.UserId == userId);

            if (enableAdmin && config != null)
            {
                config.AdminOverride = true;
                _context.SaveChanges();
            }

            return Ok(new { status = "Preview mode activated." });
        }

        private int GetCurrentUserId()
        {
            return int.Parse(User.Claims.First(c => c.Type == "user_id").Value);
        }
    }
}
