using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Orbit.Infrastructure.Data.Contexts;
using Orbit.Infrastructure.Identity;

namespace Orbit.Container;

public static class Container
{
    /// <summary>
    /// Sets up the dependency injection container with required services and configurations.
    /// </summary>
    /// <param name="services">The service collection to configure.</param>
    /// <exception cref="InvalidOperationException">Thrown when the connection string is not found in environment variables.</exception>
    public static void SetupContainer(this IServiceCollection services)
    {
        string connectionString;
        connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION")
        ?? throw new InvalidOperationException("The connection String cannot be empty.");

        services.AddDbContext<ApplicationDbContext>(options =>
        options.UseNpgsql(connectionString));

        services.AddIdentityCore<ApplicationUser>(options =>
        {
            options.Password.RequireDigit = true;
            options.Password.RequiredLength = 6;
            options.User.AllowedUserNameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._";
            options.User.RequireUniqueEmail = true;
            options.SignIn.RequireConfirmedEmail = true;
            options.SignIn.RequireConfirmedPhoneNumber = true;
        }).AddEntityFrameworkStores<ApplicationDbContext>();
    }
}
