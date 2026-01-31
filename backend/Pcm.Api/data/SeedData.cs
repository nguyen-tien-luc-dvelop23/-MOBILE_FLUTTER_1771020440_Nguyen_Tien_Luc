using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Pcm.Domain.Entities;
using Pcm.Domain.Enums;
using Pcm.Infrastructure.Data;

public static class SeedData
{
    public static async Task SeedUserAsync(IServiceProvider services)
    {
        var userManager = services.GetRequiredService<UserManager<IdentityUser>>();
        var db = services.GetRequiredService<AppDbContext>();

        // Identity admin (bonus)
        var email = "admin@pcm.com";
        var password = "123456";

        var user = await userManager.FindByEmailAsync(email);
        if (user == null)
        {
            user = new IdentityUser
            {
                UserName = email,
                Email = email,
                EmailConfirmed = true
            };

            await userManager.CreateAsync(user, password);
        }

        // Member admin theo yêu cầu chấm bài (AuthController dùng bảng Members)
        var memberAdminEmail = "luc@gmail.com";
        var memberAdminPassword = "123456";

        var memberExists = await db.Members.AnyAsync(m => m.Email == memberAdminEmail);
        if (!memberExists)
        {
            db.Members.Add(new Member
            {
                Email = memberAdminEmail,
                Password = memberAdminPassword,
                FullName = "Nguyễn Tiến Lực", // Updated name again for consistency
                IsActive = true,
                IsAdmin = true, // Force admin
                WalletBalance = 5000000,
                TotalSpent = 0,
                Tier = Tier.Diamond
            });
            await db.SaveChangesAsync();
        }
        else 
        {
            // Always ensure luc@gmail.com is admin and has correct name
            member.FullName = "Nguyễn Tiến Lực";
            member.IsAdmin = true;
            await db.SaveChangesAsync();
        }
    }
}
