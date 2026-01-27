using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pcm.Infrastructure.Data;

namespace Pcm.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MemberController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MemberController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetMembers([FromQuery] string? search, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            if (page <= 0)
                page = 1;
            if (pageSize <= 0 || pageSize > 100)
                pageSize = 20;

            var query = _context.Members.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(m => m.FullName.Contains(search) || m.Email.Contains(search));
            }

            var total = await query.CountAsync();

            var items = await query
                .OrderBy(m => m.FullName)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(new
            {
                Total = total,
                Page = page,
                PageSize = pageSize,
                Items = items
            });
        }

        [HttpGet("{id:int}/profile")]
        public async Task<IActionResult> GetProfile(int id)
        {
            var member = await _context.Members.FirstOrDefaultAsync(m => m.Id == id && m.IsActive);
            if (member == null)
                return NotFound();

            var recentBookings = await _context.Bookings
                .Include(b => b.Court)
                .Where(b => b.MemberId == id)
                .OrderByDescending(b => b.StartTime)
                .Take(10)
                .ToListAsync();

            return Ok(new
            {
                Member = member,
                RecentBookings = recentBookings
            });
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdateProfile(int id, [FromBody] UpdateProfileRequest request)
        {
            var member = await _context.Members.FindAsync(id);
            if (member == null) return NotFound();

            // Chỉ cho phép update nếu là chính mình hoặc admin (logic check quyền đơn giản là check ID trong JWT)
            // Ở đây tạm bỏ qua check role admin, chỉ check id trùng
            var memberIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier) ??
                                User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub);

            if (memberIdClaim != null && int.Parse(memberIdClaim.Value) != id)
            {
                return Forbid();
            }

            member.FullName = request.FullName ?? member.FullName;
            member.PhoneNumber = request.PhoneNumber ?? member.PhoneNumber;
            member.AvatarUrl = request.AvatarUrl ?? member.AvatarUrl;
            
            // Không update password ở đây

            await _context.SaveChangesAsync();
            return Ok(member);
        }

        [HttpPost("{id:int}/change-password")]
        public async Task<IActionResult> ChangePassword(int id, [FromBody] ChangePasswordRequest request)
        {
            var member = await _context.Members.FindAsync(id);
            if (member == null) return NotFound();

            var memberIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier) ??
                                User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub);

            if (memberIdClaim != null && int.Parse(memberIdClaim.Value) != id)
            {
                return Forbid();
            }

            // Logic đơn giản so sánh plain text theo yêu cầu đề bài
            if (member.Password != request.OldPassword)
            {
                return BadRequest("Incorrect old password");
            }

            member.Password = request.NewPassword;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Password changed successfully" });
        }
    }

    public record UpdateProfileRequest(string? FullName, string? PhoneNumber, string? AvatarUrl);
    public record ChangePasswordRequest(string OldPassword, string NewPassword);
}
