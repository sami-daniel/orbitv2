using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Orbit.Infrastructure.Data;

namespace Orbit.Container;

public static class Container
{
    public static IServiceCollection SetupContainer(this IServiceCollection services)
    {
        var connection = Environment.GetEnvironmentVariable("DB_CONNECTION");
        services.AddDbContext<Context>(options =>
        options.UseMySql(connectionString: connection, ServerVersion.AutoDetect(connection)));

// builder.Services.AddDefaultIdentity<IdentityUser>()
//    .AddEntityFrameworkStores<ApplicationDbContext>();
        return services;
    }
}