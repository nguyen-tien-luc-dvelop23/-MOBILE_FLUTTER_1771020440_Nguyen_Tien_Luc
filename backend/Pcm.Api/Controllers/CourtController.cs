using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Pcm.Infrastructure.Data;
using Pcm.Domain.Entities;

namespace Pcm.Api.Controllers
{
    [ApiController]
    [Route("api/court")]
    [Authorize]
    public class CourtController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CourtController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/court/ping
        [HttpGet("ping")]
        [AllowAnonymous]
        public IActionResult Ping() => Ok("CourtController is alive!");

        // GET: api/court
        [HttpGet]
        [AllowAnonymous] // Allow viewing courts publicly
        public async Task<IActionResult> GetAll()
        {
            var courts = await _context.Courts.ToListAsync();
            return Ok(courts);
        }

        // POST: api/court/create
        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] Court court)
        {
            var member = await GetCurrentMember();
            if (member == null || !member.IsAdmin) 
            {
                Console.WriteLine($"[AUTH_DEBUG] Access Denied for {member?.Email}. IsAdmin={member?.IsAdmin}");
                return Forbid();
            }

            if (court == null)
                return BadRequest("Court data is required");

            _context.Courts.Add(court);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetAll), new { id = court.Id }, court);
        }

        // PUT: api/court/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Court court)
        {
            var member = await GetCurrentMember();
            if (member == null || !member.IsAdmin) return Forbid();

            var existing = await _context.Courts.FindAsync(id);
            if (existing == null)
                return NotFound();

            existing.Name = court.Name;
            existing.Description = court.Description;
            existing.PricePerHour = court.PricePerHour;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/court/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var member = await GetCurrentMember();
            if (member == null || !member.IsAdmin) return Forbid();

            var court = await _context.Courts.FindAsync(id);
            if (court == null)
                return NotFound();

            _context.Courts.Remove(court);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private async Task<Member?> GetCurrentMember()
        {
            var userIdStr = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value 
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub)?.Value;

            if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int memberId)) 
                return null;

            return await _context.Members.FindAsync(memberId);
        }
    }
}
